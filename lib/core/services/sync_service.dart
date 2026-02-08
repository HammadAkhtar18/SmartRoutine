import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/habit.dart';
import '../models/user_stats.dart';
import 'notification_service.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Syncs local data to Firestore.
  Future<void> syncToCloud(List<Habit> habits, UserStats userStats) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final userDoc = _firestore.collection('users').doc(user.uid);

    // Sync Stats
    batch.set(userDoc, {
      'xp': userStats.xp,
      'level': userStats.level,
      'totalHabitsCompleted': userStats.totalHabitsCompleted,
      'currentStreak': userStats.currentStreak,
      'lastCompletionDate': userStats.lastCompletionDate?.toIso8601String(),
      'unlockedBadgeIds': userStats.unlockedBadgeIds,
      'lastSynced': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Sync Habits
    final habitsCollection = userDoc.collection('habits');
    
    // This is a simple full overwrite strategy for simplicity.
    // In a real app, you'd want delta sync.
    for (final habit in habits) {
      final habitDoc = habitsCollection.doc(habit.id);
      batch.set(habitDoc, {
        'id': habit.id,
        'title': habit.title,
        'description': habit.description,
        'category': habit.category,
        'createdAt': habit.createdAt.toIso8601String(),
        'reminderTime': habit.reminderTime?.toIso8601String(),
        'completedDates': habit.completedDates.map((e) => e.toIso8601String()).toList(),
      });
    }

    await batch.commit();
  }

  /// Syncs cloud data to local Hive boxes.
  /// Returns a list of habits merged from cloud.
  Future<List<Habit>> syncFromCloud(Box<Habit> habitsBox, Box<UserStats> statsBox) async {
    final user = _auth.currentUser;
    if (user == null) return habitsBox.values.toList();

    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      
      // Update Stats
      final userStats = statsBox.isEmpty ? UserStats() : statsBox.getAt(0)!;
      userStats.xp = data['xp'] ?? userStats.xp;
      userStats.level = data['level'] ?? userStats.level;
      userStats.totalHabitsCompleted = data['totalHabitsCompleted'] ?? userStats.totalHabitsCompleted;
      userStats.currentStreak = data['currentStreak'] ?? userStats.currentStreak;
      
      if (data['lastCompletionDate'] != null) {
        userStats.lastCompletionDate = DateTime.parse(data['lastCompletionDate']);
      }
      
      if (data['unlockedBadgeIds'] != null) {
        userStats.unlockedBadgeIds = List<String>.from(data['unlockedBadgeIds']);
      }
      
      userStats.save();
    }

    // Update Habits
    final habitsSnapshot = await userDoc.collection('habits').get();
    for (final doc in habitsSnapshot.docs) {
      final data = doc.data();
      final id = data['id'] as String?;
      
      // Skip invalid documents with missing required fields
      if (id == null || data['title'] == null || data['createdAt'] == null) {
        debugPrint('Skipping invalid habit document: ${doc.id}');
        continue;
      }
      
      Habit? existingHabit;
      try {
        existingHabit = habitsBox.values.firstWhere((h) => h.id == id);
      } catch (_) {}

      final habit = Habit(
        id: id,
        title: data['title'] as String,
        description: (data['description'] as String?) ?? '',
        category: (data['category'] as String?) ?? 'General',
        createdAt: DateTime.parse(data['createdAt'] as String),
        reminderTime: data['reminderTime'] != null ? DateTime.parse(data['reminderTime'] as String) : null,
        completedDates: (data['completedDates'] as List?)?.map((e) => DateTime.parse(e as String)).toList() ?? [],
      );

      if (existingHabit != null) {
        // Simple conflict resolution: Cloud wins
        final index = habitsBox.values.toList().indexOf(existingHabit);
        await habitsBox.putAt(index, habit);
         
        // Reschedule notification if needed
        if (habit.reminderTime != null && habit.key is int) {
           await NotificationService.cancelNotification(existingHabit.key as int);
           await NotificationService.scheduleDailyNotification(
             id: habit.key as int,
             title: habit.title,
             body: 'Don\'t forget to complete your habit!',
             time: habit.reminderTime!,
           );
        }
      } else {
        await habitsBox.add(habit);
        // After adding, key is assigned
        if (habit.reminderTime != null && habit.key is int) {
           await NotificationService.scheduleDailyNotification(
             id: habit.key as int,
             title: habit.title,
             body: 'Don\'t forget to complete your habit!',
             time: habit.reminderTime!,
           );
        }
      }
    }
    
    return habitsBox.values.toList();
  }
}
