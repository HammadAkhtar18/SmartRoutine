import 'package:hive/hive.dart';

part 'habit.g.dart';

/// Hive model representing a habit that can be tracked daily.
@HiveType(typeId: 0)
class Habit extends HiveObject {
  /// Human-friendly title for the habit.
  @HiveField(0)
  final String title;

  /// Optional description shown in the detail UI.
  @HiveField(1)
  final String description;

  /// Date the habit was created.
  @HiveField(2)
  final DateTime createdAt;

  /// All completion timestamps for the habit.
  @HiveField(3)
  final List<DateTime> completedDates;

  Habit({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.completedDates,
  });

  /// Returns true if the habit has been completed today.
  bool isCompletedToday(DateTime today) {
    return completedDates.any((date) => _isSameDay(date, today));
  }

  /// Returns the current streak count.
  int currentStreak(DateTime today) {
    if (completedDates.isEmpty) {
      return 0;
    }

    final sortedDates = completedDates.toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime cursor = DateTime(today.year, today.month, today.day);

    for (final date in sortedDates) {
      final normalized = DateTime(date.year, date.month, date.day);
      if (_isSameDay(normalized, cursor)) {
        streak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (normalized.isBefore(cursor)) {
        break;
      }
    }

    return streak;
  }

  Habit copyWith({
    String? title,
    String? description,
    List<DateTime>? completedDates,
  }) {
    return Habit(
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
