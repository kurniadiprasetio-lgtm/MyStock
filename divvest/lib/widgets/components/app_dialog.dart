import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppDialog {
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.backgroundSecondary : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.backgroundSecondary : Colors.white,
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
