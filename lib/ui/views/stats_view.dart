import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/habit_view_model.dart';
import '../theme/app_colors.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HabitViewModel>();
    final stats = viewModel.stats();
    final userStats = viewModel.userStats;
    final history = viewModel.getCompletionHistory(7);
    
    // Find max value for graph scaling
    int maxY = 0;
    history.forEach((_, count) => maxY = count > maxY ? count : maxY);
    maxY = maxY > 0 ? maxY + 1 : 5; // Add padding

    return Scaffold(
      appBar: AppBar(

        title: const Text('Insights'),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false, // No back button
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Level Header
                if (userStats != null)
                  _buildLevelHeader(userStats.level, userStats.xp),
                
                const SizedBox(height: 24),
                
                // Chart Title
                Text(
                  'Last 7 Days',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Chart Container
                Container(
                  height: 220,
                  padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              final dates = history.keys.toList();
                              if (index >= 0 && index < dates.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    DateFormat('E').format(dates[index]),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: maxY.toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: history.entries.toList().asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          gradient: AppColors.primaryGradient,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryPurple.withOpacity(0.3),
                                AppColors.primaryPurple.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stat Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatTile(
                      'Total Habits',
                      stats.totalHabits.toString(),
                      Icons.grid_view_rounded,
                      AppColors.primaryPurple,
                    ),
                    _buildStatTile(
                      'Completed',
                      userStats?.totalHabitsCompleted.toString() ?? '0',
                      Icons.check_circle_outline,
                      AppColors.success,
                    ),
                    _buildStatTile(
                      'Best Streak',
                      '${stats.bestStreak}d',
                      Icons.local_fire_department,
                      AppColors.warning,
                    ),
                    _buildStatTile(
                      'Current Streak',
                      '${userStats?.currentStreak ?? 0}d',
                      Icons.trending_up,
                      AppColors.primaryCyan,
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

  Widget _buildLevelHeader(int level, int xp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
                shadows: [
                  Shadow(
                    color: AppColors.primaryPurple,
                    blurRadius: 20,
                  )
                ],
              ),
            ),
            Text(
              '$xp Total XP',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
