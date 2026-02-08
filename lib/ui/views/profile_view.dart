import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../core/models/user_stats.dart';
import '../../core/services/badge_service.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/viewmodels/auth_view_model.dart';
import '../../core/viewmodels/habit_view_model.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/level_progress_bar.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _hapticsEnabled = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await HapticService.isEnabled();
    final notifEnabled = await _getNotificationsEnabled();
    if (mounted) {
      setState(() {
        _hapticsEnabled = enabled;
        _notificationsEnabled = notifEnabled;
      });
    }
  }

  Future<bool> _getNotificationsEnabled() async {
    final box = await Hive.openBox('settings');
    return box.get('notifications_enabled', defaultValue: true);
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final box = await Hive.openBox('settings');
    await box.put('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HabitViewModel>();
    final userStats = viewModel.userStats;

    return Scaffold(
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
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),

                // User Level Card
                if (userStats != null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Level ${userStats.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                         Text(
                          '${userStats.totalHabitsCompleted} Habits Completed',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        LevelProgressBar(
                          level: userStats.level,
                          currentXp: userStats.xp,
                          requiredXp: GamificationService().xpToNextLevel(userStats.level),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
                
                // Badges Section
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBadgesGrid(userStats),
                const SizedBox(height: 32),
                
                // Settings Section
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                GlassContainer(
                   child: Column(
                     children: [
                       _buildSettingsTile(
                         icon: Icons.notifications_outlined,
                         title: 'Notifications',
                         onTap: () => _setNotificationsEnabled(!_notificationsEnabled),
                         trailing: Switch(
                           value: _notificationsEnabled, 
                           onChanged: _setNotificationsEnabled,
                           activeColor: AppColors.primaryPurple,
                           activeTrackColor: AppColors.primaryPurple.withOpacity(0.3),
                         ),
                       ),
                       const Divider(color: AppColors.surfaceBorder, height: 1),
                       _buildSettingsTile(
                         icon: Icons.vibration,
                         title: 'Haptic Feedback',
                         onTap: () async {
                           final newValue = !_hapticsEnabled;
                           await HapticService.toggle(newValue);
                           setState(() => _hapticsEnabled = newValue);
                           if (newValue) HapticService.medium();
                         },
                         trailing: Switch(
                           value: _hapticsEnabled,
                           onChanged: (val) async {
                             await HapticService.toggle(val);
                             setState(() => _hapticsEnabled = val);
                             if (val) HapticService.light();
                           },
                           activeColor: AppColors.primaryPurple,
                           activeTrackColor: AppColors.primaryPurple.withOpacity(0.3),
                         ),
                       ),
                       const Divider(color: AppColors.surfaceBorder, height: 1),
                       _buildSettingsTile(
                         icon: Icons.shield_outlined,
                         title: 'Privacy Policy',
                         onTap: () => _showPrivacyPolicy(context),
                       ),
                       const Divider(color: AppColors.surfaceBorder, height: 1),
                       _buildSettingsTile(
                         icon: Icons.logout,
                         title: 'Log Out',
                         titleColor: AppColors.error,
                         iconColor: AppColors.error,
                         onTap: () {
                            context.read<AuthViewModel>().logout();
                            Navigator.of(context).pushReplacementNamed('/login');
                         },
                       ),
                       const Divider(color: AppColors.surfaceBorder, height: 1),
                       _buildSettingsTile(
                         icon: Icons.delete_forever,
                         title: 'Delete Account',
                         titleColor: AppColors.error,
                         iconColor: AppColors.error,
                         onTap: () => _showDeleteAccountDialog(context),
                       ),
                     ],
                   ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color titleColor = AppColors.textPrimary,
    Color iconColor = AppColors.textSecondary,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildBadgesGrid(UserStats? stats) {
    if (stats == null) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: BadgeService.allBadges.map((badge) {
        final isUnlocked = stats.unlockedBadgeIds.contains(badge.id);
        return Tooltip(
          message: isUnlocked ? badge.description : 'Locked',
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.surfaceGlass : Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked ? AppColors.primaryPurple.withOpacity(0.5) : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isUnlocked ? badge.iconPath : '🔒',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Account', style: TextStyle(color: AppColors.error)),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your habits, progress, and achievements will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          Consumer<AuthViewModel>(
            builder: (context, auth, _) => TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await context.read<AuthViewModel>().deleteAccount();
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        Navigator.of(context).pushReplacementNamed('/login');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account deleted successfully'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      } else if (auth.errorMessage != null && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(auth.errorMessage!),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        auth.clearError();
                      }
                    },
              child: auth.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                    )
                  : const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _privacySection('Data Collection', 
                'We collect your email address for authentication and your habit data to provide the service.'),
              _privacySection('Data Storage', 
                'Your data is securely stored using Firebase services with encryption at rest.'),
              _privacySection('Data Sharing', 
                'We do not sell or share your personal data with third parties.'),
              _privacySection('Your Rights', 
                'You can delete your account and all associated data at any time from the Profile settings.'),
              _privacySection('Contact', 
                'For privacy inquiries, contact us at privacy@smartroutine.app'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryCyan)),
          ),
        ],
      ),
    );
  }

  Widget _privacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          )),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          )),
        ],
      ),
    );
  }
}
