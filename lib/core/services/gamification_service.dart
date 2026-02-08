import '../models/user_stats.dart';

class GamificationService {
  static const int baseXpPerHabit = 10;
  static const double difficultyMultiplier = 1.5;

  /// Returns the XP required to reach the NEXT level.
  /// Formula: Level * 100 * 1.5
  int xpToNextLevel(int currentLevel) {
    return (currentLevel * 100 * difficultyMultiplier).toInt();
  }

  /// Awards XP and handles leveling up.
  /// Returns true if the user leveled up.
  bool awardXp(UserStats stats) {
    stats.xp += baseXpPerHabit;
    stats.totalHabitsCompleted++;
    
    int requiredXp = xpToNextLevel(stats.level);
    bool leveledUp = false;

    // Check for level up
    while (stats.xp >= requiredXp) {
      stats.xp -= requiredXp;
      stats.level++;
      requiredXp = xpToNextLevel(stats.level);
      leveledUp = true;
    }
    
    _updateStreak(stats);
    
    stats.save();
    return leveledUp;
  }

  void _updateStreak(UserStats stats) {
    final today = DateTime.now();
    final lastDate = stats.lastCompletionDate;
    
    if (lastDate != null) {
      final difference = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;
          
      if (difference == 1) {
        stats.currentStreak++;
      } else if (difference > 1) {
        stats.currentStreak = 1; // Reset if missed a day
      }
      // If difference == 0, do nothing (already updated today)
    } else {
      stats.currentStreak = 1;
    }
    stats.lastCompletionDate = today;
  }
}
