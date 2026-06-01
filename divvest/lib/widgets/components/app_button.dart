import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonType { primary, secondary, destructive, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final Widget? icon;
  final bool fullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == AppButtonType.secondary
                    ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final buttonStyle = _getButtonStyle(context, isDark);

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
          foregroundColor: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          elevation: 0,
          side: BorderSide(
            color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonType.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.labelLarge,
        );
      case AppButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTypography.labelLarge.copyWith(
            color: AppColors.primary,
          ),
        );
    }
  }
}
