import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBg = isDark ? AppColors.cardBackground : AppColors.lightCardBackground;
    final defaultRadius = isDark ? 16.0 : 14.0;
    final defaultBorder = border ??
        Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
          width: isDark ? 1 : 1.5,
        );
    final defaultShadow = boxShadow ??
        (isDark
            ? null
            : [
                const BoxShadow(
                  color: AppColors.lightCardShadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? defaultBg,
          borderRadius: BorderRadius.circular(borderRadius ?? defaultRadius),
          border: defaultBorder,
          boxShadow: defaultShadow,
        ),
        child: child,
      ),
    );
  }
}

class AppGradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppGradientCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color.fromRGBO(99, 102, 241, 0.2),
                  Color.fromRGBO(139, 92, 246, 0.15),
                ]
              : const [
                  Color(0xFF6366f1),
                  Color(0xFF8b5cf6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isDark ? 24 : 20),
        border: Border.all(
          color: isDark
              ? const Color.fromRGBO(139, 92, 246, 0.3)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF6366f1).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
