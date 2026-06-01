import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isDark ? AppColors.iconButtonBackground : AppColors.lightIconButtonBackground),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ??
                (isDark ? AppColors.iconButtonBorder : AppColors.lightIconButtonBorder),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor ??
              (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
        ),
      ),
    );
  }
}
