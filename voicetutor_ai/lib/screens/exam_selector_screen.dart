import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'language_selector_screen.dart';
import 'progress_screen.dart';

class ExamSelectorScreen extends StatelessWidget {
  const ExamSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VoiceTutor AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Progress',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: Constants.examCategories.entries.map((entry) {
                return _buildCategoryCard(context, entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Exam',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '20+ competitive exams covered',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, String category, List<String> exams) {
    final emoji = Constants.categoryEmojis[category] ?? '📚';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text('${exams.length} exams'),
        children: exams
            .map((exam) => _buildExamTile(context, exam))
            .toList(),
      ),
    );
  }

  Widget _buildExamTile(BuildContext context, String exam) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: const Icon(Icons.arrow_forward_ios_rounded,
          color: Color(0xFF6366F1), size: 16),
      title: Text(exam),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Start',
          style: TextStyle(
            color: Color(0xFF10B981),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LanguageSelectorScreen(exam: exam),
        ),
      ),
    );
  }
}
