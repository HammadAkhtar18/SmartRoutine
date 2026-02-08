import 'package:flutter/material.dart';

import '../../core/models/habit.dart';
import '../theme/app_colors.dart';

/// Premium habit card with glassmorphism and streak badge.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isDone = habit.isCompletedToday(today);
    final streak = habit.currentStreak(today);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone 
              ? const Color.fromRGBO(16, 185, 129, 0.5) 
              : AppColors.surfaceBorder,
          width: 1,
        ),
        boxShadow: isDone ? [
          BoxShadow(
            color: const Color.fromRGBO(16, 185, 129, 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom checkbox
                _buildCheckbox(isDone),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDone 
                              ? AppColors.textSecondary 
                              : AppColors.textPrimary,
                          decoration: isDone 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                      if (habit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          habit.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            decoration: isDone 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Streak badge
                if (streak > 0) ...[
                  _buildStreakBadge(streak),
                  const SizedBox(width: 8),
                ],
                
                // Menu
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  color: AppColors.backgroundElevated,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isDone) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: isDone ? AppColors.primaryGradient : null,
        color: isDone ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isDone ? null : Border.all(
          color: AppColors.textMuted,
          width: 2,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }

  Widget _buildStreakBadge(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(245, 158, 11, 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
