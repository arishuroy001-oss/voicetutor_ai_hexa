import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/practice_provider.dart';
import '../widgets/animated_mic.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String exam;
  final String language;

  const PracticeScreen({
    super.key,
    required this.exam,
    required this.language,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(practiceProvider.notifier)
          .startSession(widget.exam, widget.language);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(practiceProvider);
    final isBengali = widget.language == 'Bengali';
    final isListening = session.state == PracticeState.listeningAnswer ||
        session.state == PracticeState.listenWake;
    final isSpeaking = session.state == PracticeState.speakingQuestion ||
        session.state == PracticeState.speakingFeedback;

    return WillPopScope(
      onWillPop: () async {
        await ref.read(practiceProvider.notifier).endSession();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text('${widget.exam} Practice'),
          leading: BackButton(
            onPressed: () async {
              await ref.read(practiceProvider.notifier).endSession();
              if (mounted) Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: _StreakChip(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score Row
              _ScoreRow(session: session),
              const SizedBox(height: 24),

              // State indicator
              _StateChip(state: session.state, isBengali: isBengali),
              const SizedBox(height: 32),

              // Animated Mic — central interactive element
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedMic(
                    isListening: isListening,
                    isSpeaking: isSpeaking,
                    isGenerating:
                        session.state == PracticeState.generating,
                    isEvaluating:
                        session.state == PracticeState.evaluating,
                  ),
                ),
              ),

              // Status / Question text
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      session.statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Stop Session button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(
                    isBengali ? 'সেশন বন্ধ করুন' : 'Stop Session',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(practiceProvider.notifier).endSession();
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final PracticeSession session;
  const _ScoreRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _scoreCard('✅ Correct', session.correctCount, const Color(0xFF10B981)),
        _scoreCard('📊 Total', session.totalAttempted, const Color(0xFF6366F1)),
        _scoreCard('❌ Wrong', session.wrongCount, const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _scoreCard(String label, int val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$val',
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  final PracticeState state;
  final bool isBengali;
  const _StateChip({required this.state, required this.isBengali});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      PracticeState.idle => ('Idle', Colors.grey),
      PracticeState.listenWake => (
          isBengali ? '💤 অপেক্ষা করছি...' : '💤 Waiting for wake word',
          Colors.grey
        ),
      PracticeState.generating => (
          isBengali ? '✨ প্রশ্ন তৈরি হচ্ছে' : '✨ Generating',
          const Color(0xFF6366F1)
        ),
      PracticeState.speakingQuestion => (
          isBengali ? '🔊 প্রশ্ন পড়ছি' : '🔊 Speaking Question',
          const Color(0xFF6366F1)
        ),
      PracticeState.listeningAnswer => (
          isBengali ? '🎙 শুনছি...' : '🎙 Listening...',
          const Color(0xFF10B981)
        ),
      PracticeState.evaluating => (
          isBengali ? '🤔 মূল্যায়ন হচ্ছে' : '🤔 Evaluating',
          Colors.orange
        ),
      PracticeState.speakingFeedback => (
          isBengali ? '💬 উত্তর বলছি' : '💬 Speaking Feedback',
          const Color(0xFF6366F1)
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StreakChip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Text('🔥', style: TextStyle(fontSize: 14)),
          SizedBox(width: 4),
          Text(
            'Streak',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
