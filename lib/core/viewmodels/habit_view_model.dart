import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/habit.dart';
import '../services/hive_service.dart';

/// ViewModel for managing habits and related state.
class HabitViewModel extends ChangeNotifier {
  Box<Habit>? _habitsBox;
  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  /// Initializes the Hive box and loads data.
  Future<void> loadHabits() async {
    _habitsBox ??= await HiveService.openHabitsBox();
    _habits = _habitsBox!.values.toList();
    notifyListeners();
  }

  /// Adds a new habit.
  Future<void> addHabit({
    required String title,
    required String description,
  }) async {
    final habit = Habit(
      title: title,
      description: description,
      createdAt: DateTime.now(),
      completedDates: [],
    );
    await _habitsBox?.add(habit);
    await loadHabits();
  }

  /// Updates an existing habit.
  Future<void> updateHabit({
    required int index,
    required String title,
    required String description,
  }) async {
    final habit = _habits[index].copyWith(
      title: title,
      description: description,
    );
    await _habitsBox?.putAt(index, habit);
    await loadHabits();
  }

  /// Deletes a habit.
  Future<void> deleteHabit(int index) async {
    await _habitsBox?.deleteAt(index);
    await loadHabits();
  }

  /// Toggles completion for today.
  Future<void> toggleCompletion(int index) async {
    final habit = _habits[index];
    final today = DateTime.now();
    final updatedDates = habit.completedDates.toList();

    if (habit.isCompletedToday(today)) {
      updatedDates.removeWhere((date) => _isSameDay(date, today));
    } else {
      updatedDates.add(today);
    }

    await _habitsBox?.putAt(
      index,
      habit.copyWith(completedDates: updatedDates),
    );
    await loadHabits();
  }

  /// Calculates stats for the stats screen.
  HabitStats stats() {
    final today = DateTime.now();
    int completedToday = 0;
    int bestStreak = 0;

    for (final habit in _habits) {
      if (habit.isCompletedToday(today)) {
        completedToday += 1;
      }
      bestStreak =
          habit.currentStreak(today) > bestStreak ? habit.currentStreak(today) : bestStreak;
    }

    return HabitStats(
      totalHabits: _habits.length,
      completedToday: completedToday,
      bestStreak: bestStreak,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Simple stats model for the UI layer.
class HabitStats {
  final int totalHabits;
  final int completedToday;
  final int bestStreak;

  HabitStats({
    required this.totalHabits,
    required this.completedToday,
    required this.bestStreak,
  });
}
