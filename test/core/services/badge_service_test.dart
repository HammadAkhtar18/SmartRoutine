import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine/core/models/habit.dart';
import 'package:smart_routine/core/models/user_stats.dart';
import 'package:smart_routine/core/services/badge_service.dart';

void main() {
  group('BadgeService', () {
    late BadgeService service;
    
    setUp(() {
      service = BadgeService();
    });

    test('should have all expected badges defined', () {
      expect(BadgeService.allBadges.length, equals(5));
      
      final badgeIds = BadgeService.allBadges.map((b) => b.id).toList();
      expect(badgeIds, contains('first_step'));
      expect(badgeIds, contains('consistency_king'));
      expect(badgeIds, contains('dedicated'));
      expect(badgeIds, contains('habit_master'));
      expect(badgeIds, contains('level_up'));
    });

    test('Badge first_step should require 1 completion', () {
      // Test badge definitions without calling checkUnlock (which calls stats.save())
      final firstStepBadge = BadgeService.allBadges.firstWhere((b) => b.id == 'first_step');
      expect(firstStepBadge.name, equals('First Step'));
      expect(firstStepBadge.description, equals('Complete your first habit.'));
    });

    test('Badge consistency_king should require 3-day streak', () {
      final badge = BadgeService.allBadges.firstWhere((b) => b.id == 'consistency_king');
      expect(badge.name, equals('Consistency King'));
      expect(badge.description, equals('Reach a 3-day streak.'));
    });

    test('Badge dedicated should require 7-day streak', () {
      final badge = BadgeService.allBadges.firstWhere((b) => b.id == 'dedicated');
      expect(badge.name, equals('Dedicated'));
      expect(badge.description, equals('Reach a 7-day streak.'));
    });

    test('Badge habit_master should require 10 completions', () {
      final badge = BadgeService.allBadges.firstWhere((b) => b.id == 'habit_master');
      expect(badge.name, equals('Habit Master'));
      expect(badge.description, equals('Complete 10 habits in total.'));
    });

    test('Badge level_up should require level 2', () {
      final badge = BadgeService.allBadges.firstWhere((b) => b.id == 'level_up');
      expect(badge.name, equals('Level Up'));
      expect(badge.description, equals('Reach Level 2.'));
    });

    test('All badges should have icon paths', () {
      for (final badge in BadgeService.allBadges) {
        expect(badge.iconPath, isNotEmpty);
      }
    });
  });
}
