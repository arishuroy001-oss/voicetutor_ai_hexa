import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/user_progress.dart';

class ProgressNotifier extends StateNotifier<UserProgress> {
  ProgressNotifier() : super(UserProgress(userId: 'me')) {
    _load();
  }

  void _load() {
    final box = Hive.box<UserProgress>('progressBox');
    final stored = box.get('me');
    if (stored != null) state = stored;
  }

  Future<void> refresh() async {
    final box = Hive.box<UserProgress>('progressBox');
    final stored = box.get('me');
    if (stored != null) state = stored;
  }

  Future<void> reset() async {
    final box = Hive.box<UserProgress>('progressBox');
    final fresh = UserProgress(userId: 'me');
    await box.put('me', fresh);
    state = fresh;
  }

  Map<String, int> getWeeklyStats() {
    final historyBox = Hive.box('attemptHistory');
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    int correct = 0, total = 0;

    for (var entry in historyBox.values) {
      final date = DateTime.tryParse(entry['date'] as String? ?? '');
      if (date != null && date.isAfter(weekAgo)) {
        total++;
        if (entry['isCorrect'] as bool? ?? false) correct++;
      }
    }
    return {'correct': correct, 'total': total};
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, UserProgress>(
  (ref) => ProgressNotifier(),
);
