import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/components/components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isResetting = false;

  Future<void> _resetDatabase() async {
    final confirmed = await AppDialog.showDeleteConfirmation(
      context: context,
      title: 'Clear All Data?',
      message: 'This will delete all stocks, transactions, and dividends. This cannot be undone.',
    );

    if (confirmed == true && mounted) {
      setState(() => _isResetting = true);
      try {
        final db = await DatabaseHelper.instance.database;
        await db.execute('DELETE FROM stocks');
        await db.execute('DELETE FROM portfolio_entries');
        await db.execute('DELETE FROM dividend_records');
        if (mounted) {
          setState(() => _isResetting = false);
          AppSnackBar.showSuccess(context, 'All data cleared');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isResetting = false);
          AppSnackBar.showError(context, 'Failed to reset: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Settings',
      showBackButton: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildProfileItem(isDark),
              _buildSectionTitle('Data', isDark),
              _buildSettingsItem(
                icon: Icons.upload_file_outlined,
                title: 'Export Data',
                subtitle: 'Export to CSV/Excel',
                isDark: isDark,
              ),
              _buildSettingsItem(
                icon: Icons.backup_outlined,
                title: 'Backup & Restore',
                subtitle: 'Local file backup',
                isDark: isDark,
              ),
              _buildSettingsItem(
                icon: Icons.sync_outlined,
                title: 'Sync Prices',
                subtitle: 'Last sync: 5 min ago',
                isDark: isDark,
              ),
              _buildSettingsItem(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                subtitle: 'Delete all stocks, transactions, and dividends',
                isDark: isDark,
                onTap: _isResetting ? null : _resetDatabase,
                isLoading: _isResetting,
                iconColor: AppColors.error,
              ),
              _buildSectionTitle('Preferences', isDark),
              _buildToggleItem(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
                isDark: isDark,
              ),
              _buildToggleItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                value: true,
                onChanged: (_) {},
                isDark: isDark,
              ),
              _buildSettingsItemWithValue(
                icon: Icons.percent_outlined,
                title: 'Default Tax Rate',
                value: '10%',
                isDark: isDark,
              ),
              _buildSectionTitle('About', isDark),
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'About DivVest',
                subtitle: 'Version 1.0.0',
                isDark: isDark,
                onTap: () => AppRouter.push(context, AppRoutes.about),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _buildIconContainer(Icons.person_outline),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: AppTypography.titleSmall.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tax ID, PPh settings',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    bool isLoading = false,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildIconContainer(icon, isLoading: isLoading, iconColor: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItemWithValue({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _buildIconContainer(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildIconContainer(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: value ? AppColors.primary : (isDark ? AppColors.cardBorder : AppColors.lightCardBorder),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: value ? 25 : 4,
                      top: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.15),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, {bool isLoading = false, Color? iconColor}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(99, 102, 241, 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(99, 102, 241, 0.2),
          width: 1,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Icon(
              icon,
              size: 22,
              color: iconColor ?? const Color(0xFF6366f1),
            ),
    );
  }
}
