import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/habit_view_model.dart';
import '../widgets/stat_tile.dart';

/// Displays simple statistics about habits.
class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<HabitViewModel>().stats();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Stats')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            StatTile(label: 'Total Habits', value: stats.totalHabits.toString()),
            StatTile(label: 'Completed Today', value: stats.completedToday.toString()),
            StatTile(label: 'Best Streak', value: '${stats.bestStreak} days'),
            const StatTile(label: 'Consistency', value: 'Keep going!'),
          ],
        ),
      ),
    );
  }
}
