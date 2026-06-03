import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';
import '../models/user_progress.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../services/wake_word_service.dart';
import '../services/pyq_service.dart';
import '../utils/constants.dart';

enum PracticeState {
  idle,
  listenWake,
  generating,
  speakingQuestion,
  listeningAnswer,
  evaluating,
  speakingFeedback,
}

class PracticeSession {
  final PracticeState state;
  final Question? currentQuestion;
  final int correctCount;
  final int wrongCount;
  final String statusText;
  final List<Question> wrongQueue;
  final bool isSessionActive;
  final String? errorMessage;

  const PracticeSession({
    this.state = PracticeState.idle,
    this.currentQuestion,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.statusText = "Say 'Hey Tutor' to start",
    this.wrongQueue = const [],
    this.isSessionActive = false,
    this.errorMessage,
  });

  int get totalAttempted => correctCount + wrongCount;

  double get accuracy =>
      totalAttempted == 0 ? 0 : (correctCount / totalAttempted) * 100;

  PracticeSession copyWith({
    PracticeState? state,
    Question? currentQuestion,
    int? correctCount,
    int? wrongCount,
    String? statusText,
    List<Question>? wrongQueue,
    bool? isSessionActive,
    String? errorMessage,
  }) =>
      PracticeSession(
        state: state ?? this.state,
        currentQuestion: currentQuestion ?? this.currentQuestion,
        correctCount: correctCount ?? this.correctCount,
        wrongCount: wrongCount ?? this.wrongCount,
        statusText: statusText ?? this.statusText,
        wrongQueue: wrongQueue ?? this.wrongQueue,
        isSessionActive: isSessionActive ?? this.isSessionActive,
        errorMessage: errorMessage,
      );
}

class PracticeNotifier extends StateNotifier<PracticeSession> {
  final AIService _ai = AIService();
  final VoiceService _voice = VoiceService();
  final WakeWordService _wake = WakeWordService();
  final PYQService _pyq = PYQService();

  late String _exam;
  late String _language;
  int _retryCount = 0;
  bool _disposed = false;

  static const int _maxRetries = 3;

  PracticeNotifier() : super(const PracticeSession());

  Future<void> startSession(String exam, String language) async {
    _exam = exam;
    _language = language;
    _retryCount = 0;

    await _voice.initSpeech();
    await _voice.setLanguage(language);

    final readyMsg = language == 'Bengali'
        ? 'প্রস্তুত! "হে টিউটর" বলুন শুরু করতে।'
        : "Ready! Say 'Hey Tutor' to start.";

    final wakeInitialized = await _wake.init(_onWakeDetected);
    if (wakeInitialized) {
      await _wake.start();
    }

    if (!_disposed) {
      state = state.copyWith(
        state: PracticeState.listenWake,
        statusText: readyMsg,
        isSessionActive: true,
      );
    }
  }

  Future<void> _onWakeDetected() async {
    if (_disposed) return;
    await _wake.stop();

    final greeting = _language == 'Bengali'
        ? 'প্রস্তুত! প্রথম প্রশ্ন আসছে।'
        : 'Ready! Here comes your first question.';
    await _voice.speak(greeting);
    await _askNextQuestion();
  }

  Future<void> _askNextQuestion() async {
    if (_disposed) return;

    state = state.copyWith(
      state: PracticeState.generating,
      statusText: _language == 'Bengali' ? 'প্রশ্ন তৈরি হচ্ছে...' : 'Generating question...',
    );

    try {
      // 70% AI, 30% PYQ
      Question? q;
      final usePYQ = DateTime.now().millisecond % 10 < 3;

      if (usePYQ) {
        q = await _pyq.getRandomPYQ(exam: _exam, language: _language);
      }
      q ??= await _ai.generateQuestion(_exam, 'GK', _language);

      _retryCount = 0;

      // Cache to Hive
      final cacheBox = Hive.box<Question>('questionCache');
      await cacheBox.put(q.id, q);

      if (_disposed) return;
      state = state.copyWith(
        currentQuestion: q,
        state: PracticeState.speakingQuestion,
        statusText: q.questionText,
      );

      await _voice.speak(q.questionText);
      await _listenForAnswer();
    } catch (e) {
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final retryMsg = _language == 'Bengali'
            ? 'একটু সমস্যা হচ্ছে। আবার চেষ্টা করছি...'
            : 'Having some trouble. Trying again...';
        await _voice.speak(retryMsg);
        await Future.delayed(const Duration(seconds: 2));
        await _askNextQuestion();
      } else {
        // Fallback to cached question
        await _fallbackToCachedQuestion();
      }
    }
  }

  Future<void> _fallbackToCachedQuestion() async {
    if (_disposed) return;
    final cacheBox = Hive.box<Question>('questionCache');
    final cached = cacheBox.values
        .where((q) => !q.isExpired)
        .toList();

    if (cached.isEmpty) {
      final errMsg = _language == 'Bengali'
          ? 'ইন্টারনেট সংযোগ নেই। পরে আবার চেষ্টা করুন।'
          : 'No internet connection. Please try again later.';
      state = state.copyWith(state: PracticeState.idle, statusText: errMsg);
      return;
    }

    final q = cached[DateTime.now().millisecond % cached.length];
    state = state.copyWith(
      currentQuestion: q,
      state: PracticeState.speakingQuestion,
      statusText: q.questionText,
    );
    await _voice.speak(q.questionText);
    await _listenForAnswer();
  }

  Future<void> _listenForAnswer() async {
    if (_disposed) return;

    state = state.copyWith(
      state: PracticeState.listeningAnswer,
      statusText: _language == 'Bengali' ? 'শুনছি...' : 'Listening...',
    );

    await _voice.startListening(
      onResult: (answer) async {
        if (_disposed) return;
        await _handleVoiceCommand(answer);
      },
      onTimeout: () async {
        if (_disposed) return;
        // Timeout = "I don't know"
        await _processAnswer('');
      },
    );
  }

  Future<void> _handleVoiceCommand(String answer) async {
    final lower = answer.toLowerCase().trim();

    if (Constants.stopKeywords.any((kw) => lower.contains(kw))) {
      await endSession();
      return;
    }

    if (Constants.skipKeywords.any((kw) => lower.contains(kw))) {
      await _voice.speak(_language == 'Bengali' ? 'পরের প্রশ্ন।' : 'Skipping.');
      await _askNextQuestion();
      return;
    }

    if (Constants.repeatKeywords.any((kw) => lower.contains(kw))) {
      final q = state.currentQuestion;
      if (q != null) await _voice.speak(q.questionText);
      await _listenForAnswer();
      return;
    }

    await _processAnswer(answer);
  }

  Future<void> _processAnswer(String userAnswer) async {
    if (_disposed) return;
    final q = state.currentQuestion;
    if (q == null) {
      await _askNextQuestion();
      return;
    }

    state = state.copyWith(
      state: PracticeState.evaluating,
      statusText: _language == 'Bengali' ? 'মূল্যায়ন হচ্ছে...' : 'Evaluating...',
    );

    final result = await _ai.evaluateAnswer(
      question: q.questionText,
      correctAnswer: q.correctAnswer,
      explanation: q.explanation,
      userAnswer: userAnswer,
      language: _language,
    );

    final isCorrect = result['isCorrect'] as bool? ?? false;
    final feedback = result['feedback'] as String? ?? q.explanation;

    // Save to Hive progress
    final progressBox = Hive.box<UserProgress>('progressBox');
    final progress = progressBox.get('me') ?? UserProgress(userId: 'me');
    progress.recordAttempt(q.subject, isCorrect);
    await progressBox.put('me', progress);

    // Save attempt history
    final historyBox = Hive.box('attemptHistory');
    await historyBox.add({
      'questionId': q.id,
      'question': q.questionText,
      'correctAnswer': q.correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'subject': q.subject,
      'exam': q.exam,
      'date': DateTime.now().toIso8601String(),
    });

    if (!_disposed) {
      state = state.copyWith(
        state: PracticeState.speakingFeedback,
        correctCount: isCorrect ? state.correctCount + 1 : state.correctCount,
        wrongCount: isCorrect ? state.wrongCount : state.wrongCount + 1,
        wrongQueue: isCorrect ? state.wrongQueue : [...state.wrongQueue, q],
        statusText: feedback,
      );
    }

    await _voice.speak(feedback);
    await Future.delayed(
        const Duration(milliseconds: Constants.nextQuestionDelayMs));
    await _askNextQuestion();
  }

  Future<void> endSession() async {
    _disposed = true;
    await _voice.stopListening();
    await _voice.stopSpeaking();
    await _wake.dispose();

    final summary = _language == 'Bengali'
        ? 'সেশন শেষ। মোট ${state.totalAttempted} প্রশ্নের মধ্যে ${state.correctCount}টি সঠিক।'
        : 'Session ended. You got ${state.correctCount} out of ${state.totalAttempted} correct.';

    await _voice.speak(summary);

    if (!_disposed) {
      state = state.copyWith(
        state: PracticeState.idle,
        isSessionActive: false,
        statusText: summary,
      );
    }
    _disposed = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.dispose();
    _wake.dispose();
    super.dispose();
  }
}

final practiceProvider =
    StateNotifierProvider<PracticeNotifier, PracticeSession>(
  (ref) => PracticeNotifier(),
);
