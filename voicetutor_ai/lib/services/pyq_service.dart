import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/question.dart';

class PYQService {
  static final PYQService _instance = PYQService._internal();
  factory PYQService() => _instance;
  PYQService._internal();

  List<Map<String, dynamic>>? _pyqData;
  final Random _random = Random();

  Future<void> loadPYQs() async {
    if (_pyqData != null) return;
    try {
      final raw = await rootBundle.loadString('assets/pyq_database.json');
      final decoded = json.decode(raw);
      _pyqData = List<Map<String, dynamic>>.from(decoded['questions'] ?? []);
    } catch (e) {
      _pyqData = [];
      print('Failed to load PYQ database: $e');
    }
  }

  Future<Question?> getRandomPYQ({
    required String exam,
    required String language,
  }) async {
    await loadPYQs();
    if (_pyqData == null || _pyqData!.isEmpty) return null;

    final filtered = _pyqData!
        .where((q) =>
            (q['exam'] as String?)?.contains(exam.split(' ').first) == true ||
            (q['language'] as String?) == language)
        .toList();

    final pool = filtered.isNotEmpty ? filtered : _pyqData!;
    if (pool.isEmpty) return null;

    final raw = pool[_random.nextInt(pool.length)];
    return Question.fromJson({
      ...raw,
      'isFromPYQ': true,
      'language': language,
    });
  }
}
