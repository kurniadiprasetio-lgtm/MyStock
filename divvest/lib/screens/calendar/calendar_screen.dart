import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/components/components.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  List<DividendRecord> _monthDividends = [];
  bool _isLoading = true;

  int get _selectedYear => _focusedMonth.year;
  int get _selectedMonth => _focusedMonth.month;

  static const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _fullMonthNames = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final provider = context.read<PortfolioProvider>();
    await provider.loadPortfolio();

    final monthDividends = await provider.getDividendsByMonth(_selectedYear, _selectedMonth);

    if (mounted) {
      setState(() {
        _monthDividends = monthDividends;
        _isLoading = false;
      });
    }
  }

  void _navigateMonth(int direction) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + direction, 1);
    });
    _loadData();
  }

  void _selectMonth(int monthIndex) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, monthIndex + 1, 1);
    });
    _loadData();
  }

  String _getMonthShort(int month) => _monthNames[month - 1];
  String _getMonthFull(int month) => _fullMonthNames[month - 1];

  List<int> _getVisibleMonths() {
    final current = _focusedMonth.month;
    final result = <int>[];
    for (int i = -2; i <= 2; i++) {
      int m = current + i;
      while (m < 1) { m += 12; }
      while (m > 12) { m -= 12; }
      result.add(m);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Calendar',
      showBackButton: false,
      actions: [
        AppIconButton(
          icon: Icons.add,
          onPressed: () => AppRouter.push(context, AppRoutes.addDividend),
        ),
      ],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        child: Column(
                          children: [
                            _buildCalendarNav(isDark),
                            _buildMonthTabs(isDark),
                            if (_monthDividends.isEmpty)
                              _buildEmptyState(isDark)
                            else
                              _buildDividendList(_monthDividends, isDark),
                            _buildMonthlySummary(isDark),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCalendarNav(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _navigateMonth(-1),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
                  width: 1,
                ),
              ),
              child: Icon(Icons.chevron_left, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, size: 20),
            ),
          ),
          Text(
            '${_getMonthFull(_selectedMonth)} $_selectedYear',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => _navigateMonth(1),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
                  width: 1,
                ),
              ),
              child: Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTabs(bool isDark) {
    final visibleMonths = _getVisibleMonths();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: visibleMonths.length,
          itemBuilder: (context, index) {
            final month = visibleMonths[index];
            final isSelected = month == _selectedMonth;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _selectMonth(month - 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.inputBackground : AppColors.lightInputBackground),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.inputBorder : AppColors.lightInputBorder),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getMonthShort(month),
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No dividends for ${_getMonthFull(_selectedMonth)}',
            style: AppTypography.titleSmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a dividend record',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividendList(List<DividendRecord> dividends, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: dividends.length,
      itemBuilder: (context, index) {
        final dividend = dividends[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: AppCard(
            padding: const EdgeInsets.all(16),
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
                            style: AppTypography.displayMedium.copyWith(
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
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: isDark ? const Color.fromRGBO(255, 255, 255, 0.06) : AppColors.lightCardBorder,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'DPS',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.currency(dividend.dividendPerLot, showSymbol: false),
                          style: AppTypography.titleSmall.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Est. Income',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          FormatUtils.currencyShort(dividend.grossAmount),
                          style: AppTypography.titleSmall.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(251, 191, 36, 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFfbbf24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlySummary(bool isDark) {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final currMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryColumn(
                '${_getMonthShort(prevMonth.month)} ${prevMonth.year}',
                prevMonth,
                isDark,
              ),
              _buildSummaryColumn(
                '${_getMonthShort(currMonth.month)} ${currMonth.year}',
                currMonth,
                isDark,
                isCurrent: true,
              ),
              _buildSummaryColumn(
                '${_getMonthShort(nextMonth.month)} ${nextMonth.year}',
                nextMonth,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, DateTime month, bool isDark, {bool isCurrent = false}) {
    return FutureBuilder<List<DividendRecord>>(
      future: context.read<PortfolioProvider>().getDividendsByMonth(month.year, month.month),
      builder: (context, snapshot) {
        final total = (snapshot.data ?? []).fold<double>(0, (sum, d) => sum + d.grossAmount);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              total > 0 ? FormatUtils.currencyShort(total) : '-',
              style: AppTypography.headlineMedium.copyWith(
                color: isCurrent ? AppColors.success : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
              ),
            ),
          ],
        );
      },
    );
  }
}
