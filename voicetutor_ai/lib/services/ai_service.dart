import 'dart:convert';
import 'dart:math';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/question.dart';
import '../utils/constants.dart';

class AIService {
  late final GenerativeModel _questionModel;
  late final GenerativeModel _evalModel;
  final Random _random = Random();

  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;

  AIService._internal() {
    _questionModel = GenerativeModel(
      model: Constants.geminiModel,
      apiKey: Constants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8, // High variety for questions
        maxOutputTokens: 500,
      ),
    );

    _evalModel = GenerativeModel(
      model: Constants.geminiModel,
      apiKey: Constants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // Low temperature for consistent evaluation
        maxOutputTokens: 300,
      ),
    );
  }

  /// Generates a single question using Gemini
  Future<Question> generateQuestion(
    String exam,
    String subject,
    String language,
  ) async {
    final difficulties = ['Easy', 'Medium', 'Hard'];
    final difficulty = difficulties[_random.nextInt(difficulties.length)];

    final prompt = language == 'Bengali'
        ? _buildBengaliPrompt(exam, subject, difficulty)
        : _buildEnglishPrompt(exam, subject, difficulty);

    try {
      final response = await _questionModel.generateContent([Content.text(prompt)]);
      final rawText = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = json.decode(rawText) as Map<String, dynamic>;

      return Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exam: exam,
        subject: subject,
        questionText: data['question'] as String? ?? '',
        correctAnswer: data['correctAnswer'] as String? ?? '',
        explanation: data['explanation'] as String? ?? '',
        difficulty: data['difficulty'] as String? ?? difficulty,
        language: language,
      );
    } catch (e) {
      throw Exception('Failed to generate question: $e');
    }
  }

  /// Batch-generate multiple questions for caching
  Future<List<Question>> generateQuestionBatch({
    required String exam,
    required String language,
    int count = 5,
  }) async {
    final subjects = Constants.subjects;
    final questions = <Question>[];

    for (int i = 0; i < count; i++) {
      final subject = subjects[_random.nextInt(subjects.length)];
      try {
        final q = await generateQuestion(exam, subject, language);
        questions.add(q);
      } catch (_) {
        // Skip failed questions silently
      }
    }
    return questions;
  }

  /// Evaluate user's spoken answer against correct answer
  Future<Map<String, dynamic>> evaluateAnswer({
    required String question,
    required String correctAnswer,
    required String explanation,
    required String userAnswer,
    required String language,
  }) async {
    final iDontKnow = Constants.iDontKnowKeywords
        .any((kw) => userAnswer.toLowerCase().contains(kw));

    if (userAnswer.trim().isEmpty || iDontKnow) {
      final dontKnowFeedback = language == 'Bengali'
          ? 'কোনো অসুবিধা নেই। সঠিক উত্তর হলো $correctAnswer। $explanation'
          : "No problem! The correct answer is $correctAnswer. $explanation";
      return {'isCorrect': false, 'feedback': dontKnowFeedback};
    }

    final prompt = '''
You are evaluating a student's spoken answer to an exam question.
QUESTION: $question
CORRECT ANSWER: $correctAnswer
EXPLANATION: $explanation
STUDENT'S SPOKEN ANSWER: $userAnswer
LANGUAGE: $language

Evaluation Rules:
- The student's answer was transcribed from speech, allow minor pronunciation variations.
- Match SEMANTIC MEANING, not exact wording.
- Partial credit: if user got the main concept correct → mark as correct.
- Numbers/dates can have minor variations (e.g., "nineteen forty seven" = "1947").

Provide spoken feedback in $language:
- If CORRECT: Short praise like "সঠিক! চমৎকার!" or "Correct! Well done!"
- If WRONG: "ভুল উত্তর। সঠিক উত্তর হলো $correctAnswer। $explanation" or "Incorrect. The correct answer is $correctAnswer. $explanation"

Return ONLY valid JSON (no markdown):
{"isCorrect": true/false, "feedback": "spoken feedback string in $language"}
''';

    try {
      final response = await _evalModel.generateContent([Content.text(prompt)]);
      final cleanJson = response.text!
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final result = json.decode(cleanJson) as Map<String, dynamic>;
      return {
        'isCorrect': result['isCorrect'] as bool? ?? false,
        'feedback': result['feedback'] as String? ?? '',
      };
    } catch (e) {
      // Fallback to simple string matching
      final isCorrect = userAnswer
          .toLowerCase()
          .contains(correctAnswer.toLowerCase().split(' ').first);
      return {
        'isCorrect': isCorrect,
        'feedback': isCorrect
            ? (language == 'Bengali' ? 'সঠিক!' : 'Correct!')
            : 'The correct answer is $correctAnswer. $explanation',
      };
    }
  }

  String _buildEnglishPrompt(String exam, String subject, String difficulty) => '''
You are an expert exam question setter for Indian competitive exams.
EXAM: $exam
SUBJECT: $subject
LANGUAGE: English
DIFFICULTY: $difficulty

Task: Generate ONE high-quality factual question suitable for voice-based oral examination.
Rules:
- Answer must be SHORT (1-5 words), suitable for spoken response.
- Avoid diagrams, charts, or visual content.
- Do NOT include multiple-choice options.
- Use clear, unambiguous wording.
- Avoid questions with multiple valid answers.

OUTPUT FORMAT (strict JSON, no markdown, no extra text):
{"question": "The question text", "correctAnswer": "The correct answer (short)", "explanation": "1-2 sentence explanation", "subject": "$subject", "difficulty": "$difficulty"}
''';

  String _buildBengaliPrompt(String exam, String subject, String difficulty) => '''
আপনি ভারতীয় প্রতিযোগিতামূলক পরীক্ষার একজন বিশেষজ্ঞ প্রশ্নকর্তা।
পরীক্ষা: $exam
বিষয়: $subject
ভাষা: বাংলা
কঠিনতা: $difficulty

কাজ: ভয়েস-ভিত্তিক মৌখিক পরীক্ষার জন্য উপযুক্ত একটি উচ্চমানের প্রশ্ন তৈরি করুন।
নিয়ম:
১. উত্তর ছোট হতে হবে (১-৫ শব্দ)।
২. কোনো ডায়াগ্রাম বা ভিজ্যুয়াল উপাদান ব্যবহার করবেন না।
৩. বহু-নির্বাচনী বিকল্প দেবেন না।
৪. স্পষ্ট ভাষা ব্যবহার করুন।

আউটপুট ফরম্যাট (কঠোর JSON, কোনো markdown নয়):
{"question": "প্রশ্নটি বাংলায়", "correctAnswer": "সঠিক উত্তর (ছোট)", "explanation": "১-২ বাক্যে বাংলায় ব্যাখ্যা", "subject": "$subject", "difficulty": "$difficulty"}
''';
}
