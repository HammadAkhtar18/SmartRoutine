import '../models/badge.dart';
import '../models/habit.dart';
import '../models/user_stats.dart';

class BadgeService {
  static const List<Badge> allBadges = [
    Badge(
      id: 'first_step',
      name: 'First Step',
      description: 'Complete your first habit.',
      iconPath: '🌱',
    ),
    Badge(
      id: 'consistency_king',
      name: 'Consistency King',
      description: 'Reach a 3-day streak.',
      iconPath: '👑',
    ),
    Badge(
      id: 'dedicated',
      name: 'Dedicated',
      description: 'Reach a 7-day streak.',
      iconPath: '🔥',
    ),
    Badge(
      id: 'habit_master',
      name: 'Habit Master',
      description: 'Complete 10 habits in total.',
      iconPath: '🏆',
    ),
     Badge(
      id: 'level_up',
      name: 'Level Up',
      description: 'Reach Level 2.',
      iconPath: '⭐',
    ),
  ];

  /// Checks for new badges and returns them.
  List<Badge> checkUnlock(UserStats stats, List<Habit> habits) {
    final newBadges = <Badge>[];

    for (final badge in allBadges) {
      if (stats.unlockedBadgeIds.contains(badge.id)) continue;

      bool unlocked = false;
      switch (badge.id) {
        case 'first_step':
          unlocked = stats.totalHabitsCompleted >= 1;
          break;
        case 'consistency_king':
          unlocked = stats.currentStreak >= 3;
          break;
        case 'dedicated':
          unlocked = stats.currentStreak >= 7;
          break;
        case 'habit_master':
          unlocked = stats.totalHabitsCompleted >= 10;
          break;
        case 'level_up':
          unlocked = stats.level >= 2;
          break;
      }

      if (unlocked) {
        stats.unlockedBadgeIds.add(badge.id);
        newBadges.add(badge);
      }
    }
    
    if (newBadges.isNotEmpty) {
      stats.save();
    }

    return newBadges;
  }
}
