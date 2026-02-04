import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

/// Handles Hive initialization and box access.
class HiveService {
  static const String habitsBoxName = 'habits';

  /// Initialize Hive and register adapters.
  static Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitAdapter());
    }
  }

  /// Opens the habits box.
  static Future<Box<Habit>> openHabitsBox() async {
    return Hive.openBox<Habit>(habitsBoxName);
  }
}
