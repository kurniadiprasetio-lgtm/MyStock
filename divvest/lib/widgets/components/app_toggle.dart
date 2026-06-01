import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppToggle<T> extends StatelessWidget {
  final List<AppToggleItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double height;

  const AppToggle({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
        ),
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.value),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primary.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.label,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppToggleItem<T> {
  final T value;
  final String label;

  const AppToggleItem({required this.value, required this.label});
}
