import 'package:hive/hive.dart';

part 'question.g.dart';

// Run: flutter pub run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String exam;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final String questionText;

  @HiveField(4)
  final String correctAnswer;

  @HiveField(5)
  final String explanation;

  @HiveField(6)
  final String difficulty;

  @HiveField(7)
  final String language;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final bool isFromPYQ;

  Question({
    required this.id,
    required this.exam,
    required this.subject,
    required this.questionText,
    required this.correctAnswer,
    required this.explanation,
    this.difficulty = 'Medium',
    required this.language,
    DateTime? timestamp,
    this.isFromPYQ = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String? ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        exam: json['exam'] as String? ?? '',
        subject: json['subject'] as String? ?? 'GK',
        questionText: json['question'] as String? ?? '',
        correctAnswer: json['correctAnswer'] as String? ?? '',
        explanation: json['explanation'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'Medium',
        language: json['language'] as String? ?? 'English',
        isFromPYQ: json['isFromPYQ'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam': exam,
        'subject': subject,
        'question': questionText,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'difficulty': difficulty,
        'language': language,
        'isFromPYQ': isFromPYQ,
      };

  bool get isExpired {
    final ttlDays = 7;
    return DateTime.now().difference(timestamp).inDays >= ttlDays;
  }
}
