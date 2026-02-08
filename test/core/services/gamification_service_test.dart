import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine/core/models/user_stats.dart';
import 'package:smart_routine/core/services/gamification_service.dart';

void main() {
  group('GamificationService', () {
    late GamificationService service;
    
    setUp(() {
      service = GamificationService();
    });

    test('xpToNextLevel should return correct XP for each level', () {
      // Formula: Level * 100 * 1.5
      expect(service.xpToNextLevel(1), equals(150));
      expect(service.xpToNextLevel(2), equals(300));
      expect(service.xpToNextLevel(5), equals(750));
      expect(service.xpToNextLevel(10), equals(1500));
    });

    test('baseXpPerHabit should be 10', () {
      expect(GamificationService.baseXpPerHabit, equals(10));
    });

    test('difficultyMultiplier should be 1.5', () {
      expect(GamificationService.difficultyMultiplier, equals(1.5));
    });
  });

  group('UserStats', () {
    test('should have correct default values', () {
      final stats = UserStats();
      
      expect(stats.xp, equals(0));
      expect(stats.level, equals(1));
      expect(stats.totalHabitsCompleted, equals(0));
      expect(stats.currentStreak, equals(0));
      expect(stats.lastCompletionDate, isNull);
      expect(stats.unlockedBadgeIds, isEmpty);
    });

    test('should accept custom values', () {
      final stats = UserStats(
        xp: 100,
        level: 5,
        totalHabitsCompleted: 50,
        currentStreak: 7,
        lastCompletionDate: DateTime(2026, 2, 8),
        unlockedBadgeIds: ['first_step', 'level_up'],
      );
      
      expect(stats.xp, equals(100));
      expect(stats.level, equals(5));
      expect(stats.totalHabitsCompleted, equals(50));
      expect(stats.currentStreak, equals(7));
      expect(stats.lastCompletionDate, equals(DateTime(2026, 2, 8)));
      expect(stats.unlockedBadgeIds.length, equals(2));
    });
  });
}
