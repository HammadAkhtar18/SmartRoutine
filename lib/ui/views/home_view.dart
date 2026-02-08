import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';

import '../../core/models/badge.dart';


import 'package:flutter_animate/flutter_animate.dart';
import '../../core/viewmodels/habit_view_model.dart';
import '../../core/services/gamification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/habit_card.dart';
import '../widgets/level_progress_bar.dart';
import '../../core/services/notification_service.dart';

/// Premium home dashboard with progress indicator.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  StreamSubscription? _badgeSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final viewModel = context.read<HabitViewModel>();
      viewModel.loadHabits();
      NotificationService.requestPermissions();
      
      _badgeSubscription = viewModel.badgeStream.listen((badge) {
        if (mounted) {
          _showBadgeDialog(badge);
        }
      });
    });
  }

  @override
  void dispose() {
    _badgeSubscription?.cancel();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => context.read<HabitViewModel>().clearError(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<HabitViewModel>(
            builder: (context, viewModel, _) {
              // Show error if present
              if (viewModel.errorMessage != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showError(viewModel.errorMessage!);
                  viewModel.clearError();
                });
              }

              return CustomScrollView(
                slivers: [
                  // App bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getGreeting()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'SmartRoutine',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          // Actions moved to BottomNav/Profile
                          Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: AppColors.surfaceGlass,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: AppColors.surfaceBorder),
                             ),
                             child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                          ),
                        ],
                      ),

                    ),
                  ),
                  
                  // Progress card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildProgressCard(viewModel),
                    ),
                  ),
                  
                  // Section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Your Routine",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${viewModel.habits.length} habits',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Loading indicator
                  if (viewModel.isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    )
                  // Empty state
                  else if (viewModel.habits.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceGlass,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.add_task,
                                size: 48,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first habit',
                              style: TextStyle(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Habits list
                  else ...[
                    for (final entry in viewModel.habitsByCategory.entries) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final habit = entry.value[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: HabitCard(
                                  habit: habit,
                                  onToggle: () => viewModel.toggleCompletion(habit.id),
                                  onEdit: () {
                                    Navigator.of(context).pushNamed(
                                      '/habit-form',
                                      arguments: HabitFormArgs(id: habit.id),
                                    );
                                  },
                                  onDelete: () => viewModel.deleteHabit(habit.id),
                                ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.2, end: 0),
                              );
                            },
                            childCount: entry.value.length,
                          ),
                        ),
                      ),
                    ],
                    const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.buttonShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/habit-form');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildProgressCard(HabitViewModel viewModel) {
    final userStats = viewModel.userStats;
    final stats = viewModel.stats();
    final progress = stats.totalHabits > 0 
        ? stats.completedToday / stats.totalHabits 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.completedToday} of ${stats.totalHabits} completed',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromRGBO(255, 255, 255, 0.8),
                      ),
                    ),
                    if (stats.bestStreak > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            'Best streak: ${stats.bestStreak} days',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromRGBO(255, 255, 255, 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          if (userStats != null) ...[
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 20),
            LevelProgressBar(
              level: userStats.level,
              currentXp: userStats.xp,
              requiredXp: GamificationService().xpToNextLevel(userStats.level),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  void _showBadgeDialog(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.cardShadow,
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Badge Unlocked! 🎉',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                badge.iconPath,
                style: const TextStyle(fontSize: 64),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                badge.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arguments passed to the habit form.
class HabitFormArgs {
  final String? id;

  HabitFormArgs({this.id});
}
