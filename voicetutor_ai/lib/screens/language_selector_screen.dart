import 'package:flutter/material.dart';
import 'practice_screen.dart';

class LanguageSelectorScreen extends StatelessWidget {
  final String exam;

  const LanguageSelectorScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exam),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.translate_rounded,
                size: 72, color: Color(0xFF6366F1)),
            const SizedBox(height: 24),
            const Text(
              'Choose Language',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select the language for questions and answers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            _buildLanguageCard(
              context,
              label: 'বাংলা',
              subtitle: 'Bengali (bn-IN)',
              code: 'Bengali',
              flag: '🇮🇳',
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 20),
            _buildLanguageCard(
              context,
              label: 'English',
              subtitle: 'English (en-IN)',
              code: 'English',
              flag: '🔤',
              color: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String label,
    required String subtitle,
    required String code,
    required String flag,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PracticeScreen(exam: exam, language: code),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.4), width: 2),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), color.withOpacity(0.12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: color.withOpacity(0.7), fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
