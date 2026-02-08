import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../models/user_stats.dart';

/// Handles Hive initialization and box access.
class HiveService {
  static const String habitsBoxName = 'habits';

  /// Initialize Hive and register adapters.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserStatsAdapter());
    }
  }

  /// Opens the habits box.
  static Future<Box<Habit>> openHabitsBox() async {
    return Hive.openBox<Habit>(habitsBoxName);
  }

  /// Opens the user stats box.
  static Future<Box<UserStats>> openUserStatsBox() async {
    return Hive.openBox<UserStats>('user_stats');
  }
  /// Opens the settings box.
  static Future<Box> openSettingsBox() async {
    return Hive.openBox('settings');
  }
}
