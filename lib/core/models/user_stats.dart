import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 1)
class UserStats extends HiveObject {
  @HiveField(0)
  int xp;

  @HiveField(1)
  int level;

  @HiveField(2)
  int totalHabitsCompleted;

  @HiveField(3)
  int currentStreak;

  @HiveField(4)
  DateTime? lastCompletionDate;

  @HiveField(5)
  List<String> unlockedBadgeIds;

  UserStats({
    this.xp = 0,
    this.level = 1,
    this.totalHabitsCompleted = 0,
    this.currentStreak = 0,
    this.lastCompletionDate,
    List<String>? unlockedBadgeIds,
  }) : unlockedBadgeIds = unlockedBadgeIds ?? [];
}
