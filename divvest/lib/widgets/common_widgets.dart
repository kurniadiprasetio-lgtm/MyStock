import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackground : AppColors.lightCardBackground,
          borderRadius: BorderRadius.circular(isDark ? 20 : 16),
          border: Border.all(
            color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
            width: isDark ? 1 : 1.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.lightCardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GradientCard({
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

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? change;
  final bool changePositive;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.change,
    this.changePositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightCardBackground,
        borderRadius: BorderRadius.circular(isDark ? 16 : 14),
        border: Border.all(
          color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
          width: isDark ? 1 : 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.lightCardShadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: 4),
            Text(
              change!,
              style: TextStyle(
                fontSize: 11,
                color: changePositive ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class BEPProgressBar extends StatelessWidget {
  final double percentage;
  final String covered;
  final String remaining;

  const BEPProgressBar({
    super.key,
    required this.percentage,
    required this.covered,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: isDark
                ? const Color.fromRGBO(255, 255, 255, 0.1)
                : const Color.fromRGBO(0, 0, 0, 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              covered,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
            Text(
              remaining,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BEPCircularProgress extends StatelessWidget {
  final double percentage;
  final String covered;
  final String remaining;
  final double size;

  const BEPCircularProgress({
    super.key,
    required this.percentage,
    required this.covered,
    required this.remaining,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? const Color.fromRGBO(255, 255, 255, 0.1)
                      : const Color.fromRGBO(0, 0, 0, 0.08),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'tercover',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Covered',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  covered,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class StockLogo extends StatelessWidget {
  final String ticker;
  final double size;

  const StockLogo({
    super.key,
    required this.ticker,
    this.size = 44,
  });

  Color get _color {
    final hash = ticker.hashCode;
    final colors = [
      const Color(0xFF3b82f6),
      const Color(0xFF14b8a6),
      const Color(0xFFef4444),
      const Color(0xFF10b981),
      const Color(0xFF8b5cf6),
      const Color(0xFFf59e0b),
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color, _color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          ticker[0],
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final String label;
  final bool isReinvest;

  const Badge({
    super.key,
    required this.label,
    required this.isReinvest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isReinvest
            ? const Color.fromRGBO(16, 185, 129, 0.12)
            : const Color.fromRGBO(245, 158, 11, 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isReinvest
              ? const Color.fromRGBO(16, 185, 129, 0.3)
              : const Color.fromRGBO(245, 158, 11, 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isReinvest ? AppColors.success : AppColors.warning,
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
