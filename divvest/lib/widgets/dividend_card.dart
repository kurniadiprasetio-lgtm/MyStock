import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format_utils.dart';
import '../data/models/models.dart';

class DividendCard extends StatelessWidget {
  final DividendRecord dividend;
  final VoidCallback? onTap;
  final bool showNetAmount;

  const DividendCard({
    super.key,
    required this.dividend,
    this.onTap,
    this.showNetAmount = false,
  });

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lotsHeld = dividend.lotsHeldAtExDate;
    final isUpcoming = dividend.exDate.isAfter(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(99, 102, 241, 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromRGBO(99, 102, 241, 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${dividend.exDate.day}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        _getMonthShort(dividend.exDate.month),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dividend.ticker,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ex: ${FormatUtils.dateShort(dividend.exDate)} • Pay: ${FormatUtils.dateShort(dividend.paymentDate)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUpcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(251, 191, 36, 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFfbbf24),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: isDark ? const Color.fromRGBO(255, 255, 255, 0.06) : AppColors.lightCardBorder,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountColumn('Div/Lot', FormatUtils.currency(dividend.dividendPerLot, showSymbol: false), isDark),
                _buildAmountColumn(
                  showNetAmount ? 'Net' : 'Est. Income',
                  FormatUtils.currencyShort(showNetAmount ? dividend.netAmount : dividend.grossAmount),
                  isDark,
                ),
                if (lotsHeld > 0)
                  _buildAmountColumn('Lots', '$lotsHeld', isDark),
                if (lotsHeld == 0)
                  _buildAmountColumn('Lots', '-', isDark, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountColumn(String label, String value, bool isDark, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            color: color ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
