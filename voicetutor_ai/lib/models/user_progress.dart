import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 1)
class UserProgress extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  int totalAttempted;

  @HiveField(2)
  int totalCorrect;

  @HiveField(3)
  int currentStreak;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  DateTime? lastPracticeDate;

  @HiveField(6)
  Map<String, Map<String, int>> topicWiseScore;

  UserProgress({
    required this.userId,
    this.totalAttempted = 0,
    this.totalCorrect = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPracticeDate,
    Map<String, Map<String, int>>? topicWiseScore,
  }) : topicWiseScore = topicWiseScore ?? {};

  double get accuracy =>
      totalAttempted == 0 ? 0.0 : (totalCorrect / totalAttempted) * 100;

  int get totalWrong => totalAttempted - totalCorrect;

  /// Record an attempt for a given subject
  void recordAttempt(String subject, bool isCorrect) {
    totalAttempted++;
    if (isCorrect) totalCorrect++;

    topicWiseScore.putIfAbsent(subject, () => {'correct': 0, 'total': 0});
    topicWiseScore[subject]!['total'] = (topicWiseScore[subject]!['total'] ?? 0) + 1;
    if (isCorrect) {
      topicWiseScore[subject]!['correct'] =
          (topicWiseScore[subject]!['correct'] ?? 0) + 1;
    }
    updateStreak();
  }

  /// Update daily streak
  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPracticeDate == null) {
      currentStreak = 1;
    } else {
      final last = lastPracticeDate!;
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 0) {
        // Same day — no change
      } else if (diff == 1) {
        currentStreak++;
      } else {
        currentStreak = 1; // Broken streak
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
    lastPracticeDate = today;
  }
}
