import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final weeklyStats =
        ref.read(progressProvider.notifier).getWeeklyStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(progressProvider.notifier).refresh(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Stats Grid
          _buildStatsGrid(progress),
          const SizedBox(height: 20),

          // Weekly Summary
          _buildWeeklyCard(weeklyStats),
          const SizedBox(height: 20),

          // Topic-wise Performance
          if (progress.topicWiseScore.isNotEmpty) ...[
            const Text(
              'Topic-wise Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            ...progress.topicWiseScore.entries
                .map((e) => _buildTopicTile(e.key, e.value))
                ,
          ],

          const SizedBox(height: 24),
          // Reset button
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Reset Progress',
                style: TextStyle(color: Colors.red)),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Progress?'),
                  content: const Text('This will delete all your progress data.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(progressProvider.notifier).reset();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(progress) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statCard('📚 Total Attempted', '${progress.totalAttempted}',
            const Color(0xFF6366F1)),
        _statCard(
          '✅ Accuracy',
          '${progress.accuracy.toStringAsFixed(1)}%',
          const Color(0xFF10B981),
        ),
        _statCard('🔥 Current Streak', '${progress.currentStreak} days',
            Colors.orange),
        _statCard('🏆 Best Streak', '${progress.longestStreak} days',
            const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard(Map<String, int> stats) {
    final total = stats['total'] ?? 0;
    final correct = stats['correct'] ?? 0;
    final pct = total == 0 ? 0.0 : correct / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This Week',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$correct / $total questions',
                    style: const TextStyle(fontSize: 15)),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey[200],
                color: const Color(0xFF10B981),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicTile(String topic, Map<String, int> scores) {
    final total = scores['total'] ?? 0;
    final correct = scores['correct'] ?? 0;
    final pct = total == 0 ? 0.0 : correct / total;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(topic, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey[200],
            color: pct >= 0.7
                ? const Color(0xFF10B981)
                : pct >= 0.4
                    ? Colors.orange
                    : const Color(0xFFEF4444),
            minHeight: 6,
          ),
        ),
        trailing: Text(
          '$correct/$total',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
