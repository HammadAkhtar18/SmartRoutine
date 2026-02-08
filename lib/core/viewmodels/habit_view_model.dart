import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'dart:async';
import '../models/badge.dart';
import '../models/habit.dart';
import '../models/user_stats.dart';
import '../services/badge_service.dart';
import '../services/gamification_service.dart';
import '../services/hive_service.dart';
import '../services/haptic_service.dart';

import '../services/notification_service.dart';
import '../services/sync_service.dart';

/// ViewModel for managing habits and related state.
class HabitViewModel extends ChangeNotifier {
  Box<Habit>? _habitsBox;
  Box<UserStats>? _userStatsBox;
  List<Habit> _habits = [];
  UserStats? _userStats;
  bool _isLoading = false;
  String? _errorMessage;
  final GamificationService _gamificationService = GamificationService();

  final BadgeService _badgeService = BadgeService();
  final SyncService _syncService = SyncService();
  final _badgeStreamController = StreamController<Badge>.broadcast();

  Stream<Badge> get badgeStream => _badgeStreamController.stream;

  List<Habit> get habits => _habits;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, List<Habit>> get habitsByCategory {
    final grouped = <String, List<Habit>>{};
    for (final habit in _habits) {
      if (!grouped.containsKey(habit.category)) {
        grouped[habit.category] = [];
      }
      grouped[habit.category]!.add(habit);
    }
    return grouped;
  }

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Initializes the Hive box and loads data.
  Future<void> loadHabits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _habitsBox ??= await HiveService.openHabitsBox();
      _habits = _habitsBox!.values.toList();
      
      _userStatsBox ??= await HiveService.openUserStatsBox();
      if (_userStatsBox!.isEmpty) {
        await _userStatsBox!.add(UserStats());
      }
      _userStats = _userStatsBox!.getAt(0);

      // cloud sync
      try {
        _habits = await _syncService.syncFromCloud(_habitsBox!, _userStatsBox!);
        // reload stats ref after sync
         if (_userStatsBox!.isNotEmpty) {
           _userStats = _userStatsBox!.getAt(0);
         }
        notifyListeners();
      } catch (e) {
        debugPrint('Sync failed (likely offline or no firebase setup): $e');
      }


    } catch (e) {
      _errorMessage = 'Failed to load habits: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new habit.
  Future<void> addHabit({
    required String title,
    required String description,
    required String category,
    DateTime? reminderTime,
  }) async {
    try {
      // Ensure the box is initialized
      _habitsBox ??= await HiveService.openHabitsBox();
      
      final habit = Habit(
        title: title,
        description: description,
        category: category,
        createdAt: DateTime.now(),
        completedDates: [],
        reminderTime: reminderTime,
      );
      
      await _habitsBox!.add(habit);
      debugPrint('Habit added successfully: ${habit.title}, ID: ${habit.id}');
      
      // Schedule notification if reminderTime is set
      if (reminderTime != null) {
        // Use hashcode of ID (needs improvement as String hashcode can collide or change, but for demo okay)
        // Better: store int id or use a map.
        // For HiveObject, `key` is int if box is int-indexed, but here `id` is String.
        // I'll use `habit.key` if available after add.
        // Hive keys are usually int if not specified.
        if (habit.isInBox) {
           await NotificationService.scheduleDailyNotification(
             id: habit.key as int,
             title: 'Time for $title',
             body: 'Don\'t forget your habit!',
             time: reminderTime,
           );
        }
      }
      
      // Reload habits to update the list
      _habits = _habitsBox!.values.toList();
      notifyListeners();
      
      // Initialize user stats if needed
      _userStatsBox ??= await HiveService.openUserStatsBox();
      if (_userStatsBox!.isEmpty) {
        await _userStatsBox!.add(UserStats());
      }
      _userStats = _userStatsBox!.getAt(0);
      
      // Sync to cloud
      if (_userStats != null) {
        _syncService.syncToCloud(_habits, _userStats!).catchError((e) {
           debugPrint('Sync failed: $e');
        });
      }
    } catch (e) {
      debugPrint('Error adding habit: $e');
      _errorMessage = 'Failed to add habit: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Updates an existing habit by ID.
  Future<void> updateHabit({
    required String id,
    required String title,
    required String description,
    required String category,
    DateTime? reminderTime,
  }) async {
    try {
      // Ensure the box is initialized
      _habitsBox ??= await HiveService.openHabitsBox();
      
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) {
        _errorMessage = 'Habit not found';
        notifyListeners();
        return;
      }
      final oldHabit = _habits[index];
      final habit = oldHabit.copyWith(
        title: title,
        description: description,
        category: category,
        reminderTime: reminderTime,
      );
      await _habitsBox!.putAt(index, habit);
      
      // Handle notification update
      if (habit.isInBox) {
        final notificationId = habit.key as int;
        await NotificationService.cancelNotification(notificationId);
        if (reminderTime != null) {
          await NotificationService.scheduleDailyNotification(
             id: notificationId,
             title: 'Time for $title',
             body: 'Don\'t forget your habit!',
             time: reminderTime,
           );
        }
      }

      await loadHabits();

      if (_userStats != null) {
        _syncService.syncToCloud(_habits, _userStats!).catchError((e) {
           debugPrint('Sync failed: $e');
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to update habit: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Deletes a habit by ID.
  Future<void> deleteHabit(String id) async {
    try {
      // Ensure the box is initialized
      _habitsBox ??= await HiveService.openHabitsBox();
      
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return;
      
      final habit = _habits[index];
      if (habit.isInBox) {
         await NotificationService.cancelNotification(habit.key as int);
      }
      
      await _habitsBox!.deleteAt(index);
      await loadHabits();

      if (_userStats != null) {
        _syncService.syncToCloud(_habits, _userStats!).catchError((e) {
           debugPrint('Sync failed: $e');
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to delete habit: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Toggles completion for today by habit ID.
  Future<void> toggleCompletion(String id) async {
    try {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index == -1) return;
      
      final habit = _habits[index];
      final today = DateTime.now();
      final updatedDates = habit.completedDates.toList();

      if (habit.isCompletedToday(today)) {
        updatedDates.removeWhere((date) => _isSameDay(date, today));
        await HapticService.light();
      } else {
        updatedDates.add(today);
        // Award XP only on completion
        if (_userStats != null) {
          final leveledUp = _gamificationService.awardXp(_userStats!);
          if (leveledUp) {
            await HapticService.heavy();
          } else {
             await HapticService.medium();
          }

          // Check for badges
          final newBadges = _badgeService.checkUnlock(_userStats!, _habits);
          for (final badge in newBadges) {
            _badgeStreamController.add(badge);
            await HapticService.heavy(); // Celebrate!
          }
        } else {
           await HapticService.medium();
        }
      }

      await _habitsBox?.putAt(
        index,
        habit.copyWith(completedDates: updatedDates),
      );
      await loadHabits();

      if (_userStats != null) {
        _syncService.syncToCloud(_habits, _userStats!).catchError((e) {
           debugPrint('Sync failed: $e');
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle completion: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Gets a habit by ID.
  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
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

  @override
  void dispose() {
    _badgeStreamController.close();
    super.dispose();
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns a map of date to completion count for the last [days].
  Map<DateTime, int> getCompletionHistory(int days) {
    final history = <DateTime, int>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Initialize with 0
    for (int i = (days - 1); i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      history[date] = 0;
    }

    // Aggregate
    for (final habit in _habits) {
      for (final date in habit.completedDates) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        if (history.containsKey(normalizedDate)) {
          history[normalizedDate] = history[normalizedDate]! + 1;
        }
      }
    }

    return history;
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

