import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine/core/models/habit.dart';

void main() {
  group('Habit Model', () {
    test('should generate unique ID when not provided', () {
      final habit1 = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: DateTime.now(),
        completedDates: [],
      );
      final habit2 = Habit(
        title: 'Test Habit 2',
        description: 'Description 2',
        createdAt: DateTime.now(),
        completedDates: [],
      );

      expect(habit1.id, isNotEmpty);
      expect(habit2.id, isNotEmpty);
      expect(habit1.id, isNot(habit2.id));
    });

    test('should use provided ID when given', () {
      final habit = Habit(
        id: 'custom-id-123',
        title: 'Test Habit',
        description: 'Description',
        createdAt: DateTime.now(),
        completedDates: [],
      );

      expect(habit.id, equals('custom-id-123'));
    });

    test('should use default category when not provided', () {
      final habit = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: DateTime.now(),
        completedDates: [],
      );

      expect(habit.category, equals('General'));
    });

    test('isCompletedToday should return true when habit is completed today', () {
      final today = DateTime.now();
      final habit = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: today,
        completedDates: [today],
      );

      expect(habit.isCompletedToday(today), isTrue);
    });

    test('isCompletedToday should return false when habit is not completed today', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final habit = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: yesterday,
        completedDates: [yesterday],
      );

      expect(habit.isCompletedToday(today), isFalse);
    });

    test('currentStreak should return 0 when no completions', () {
      final today = DateTime.now();
      final habit = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: today,
        completedDates: [],
      );

      expect(habit.currentStreak(today), equals(0));
    });

    test('currentStreak should count consecutive days', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      
      final habit = Habit(
        title: 'Test Habit',
        description: 'Description',
        createdAt: twoDaysAgo,
        completedDates: [twoDaysAgo, yesterday, today],
      );

      expect(habit.currentStreak(today), equals(3));
    });

    test('copyWith should create a copy with updated values', () {
      final habit = Habit(
        title: 'Original',
        description: 'Original Desc',
        createdAt: DateTime.now(),
        completedDates: [],
        category: 'Health',
      );

      final copy = habit.copyWith(
        title: 'Updated',
        description: 'Updated Desc',
      );

      expect(copy.id, equals(habit.id));
      expect(copy.title, equals('Updated'));
      expect(copy.description, equals('Updated Desc'));
      expect(copy.category, equals('Health'));
    });
  });
}
