import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../data/datasources/remote/yahoo_finance_api.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../providers/portfolio_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/components/components.dart';

class StockDetailScreen extends StatefulWidget {
  final String ticker;

  const StockDetailScreen({super.key, required this.ticker});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  final _repository = PortfolioRepository();
  StockSummary? _summary;
  List<PortfolioEntry> _entries = [];
  List<DividendRecord> _dividends = [];
  List<Map<String, dynamic>> _priceHistory = [];
  bool _isLoading = true;
  // API range values (e.g., '1mo', '3mo', '6mo', '1y', etc.)
  String _selectedRange = '1mo'; // default to 1 month
  // Mapping from API range to short display label
  static const Map<String, String> _rangeDisplayMap = {
    '1d': '1d',
    '1w': '1w',
    '1mo': '1m',
    '3mo': '3m',
    '6mo': '6m',
    '1y': '1y',
    '3y': '3y',
    '5y': '5y',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final detail = await YahooFinanceApi.fetchStockDetail(widget.ticker);
      if (detail != null && mounted) {
        final stock = await _repository.getStock(widget.ticker);
        if (stock != null) {
          final price = detail['price'] as double;
          final change = detail['change'] as double;
          final changePercent = detail['changePercent'] as double;
          await _repository.updateStockPrice(widget.ticker, price, change, changePercent);
        }
      }

      final history = await YahooFinanceApi.fetchPriceHistory(widget.ticker, range: _selectedRange);
      if (history != null && mounted) {
        setState(() => _priceHistory = history);
      }

      final summary = await _repository.getStockSummary(widget.ticker);
      final entries = await _repository.getEntriesByTicker(widget.ticker);
      final dividends = await _repository.getDividendsByTicker(widget.ticker);

      if (!mounted) return;
      setState(() {
        _summary = summary;
        _entries = entries;
        _dividends = dividends;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _changeRange(String range) {
    setState(() => _selectedRange = range);
    _loadData();
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    if (_entries.isEmpty) return;

    final confirmed = await AppDialog.showDeleteConfirmation(
      context: context,
      title: 'Delete All ${widget.ticker} Data?',
      message: 'This will delete ${_entries.length} transaction(s) and ${_dividends.length} dividend record(s) for ${widget.ticker}. This action cannot be undone.',
    );

    if (confirmed == true && mounted) {
      await context.read<PortfolioProvider>().deleteAllForTicker(widget.ticker);
      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(context, 'All data deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Detail',
      actions: [
        AppIconButton(
          icon: Icons.edit_outlined,
          onPressed: _entries.isNotEmpty
              ? () => AppRouter.push(
                    context,
                    AppRoutes.editTransaction,
                    arguments: _entries.first,
                  ).then((_) => _loadData())
              : null,
        ),
        const SizedBox(width: 8),
        AppIconButton(
          icon: Icons.delete_outline,
          onPressed: _entries.isNotEmpty ? () => _showDeleteDialog(context) : null,
          backgroundColor: const Color.fromRGBO(239, 68, 68, 0.1),
          borderColor: const Color.fromRGBO(239, 68, 68, 0.3),
          iconColor: _entries.isNotEmpty ? AppColors.error : AppColors.error.withValues(alpha: 0.5),
        ),
      ],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : _summary == null
                ? Center(
                    child: Text(
                      'Stock not found',
                      style: TextStyle(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await _loadData();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(_summary!, isDark),
                                _buildMetrics(_summary!, isDark),
                                _buildChart(isDark),
                                _buildBEPCard(_summary!, isDark),
                                SectionHeader(title: 'Dividend History'),
                                _buildDividendHistory(_dividends, isDark),
                                SectionHeader(title: 'Buy History'),
                                _buildBuyHistory(_entries, isDark),
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

  Widget _buildHeader(StockSummary summary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StockLogo(ticker: summary.stock.ticker, size: 60),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.stock.ticker,
                    style: AppTypography.displayMedium.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary.stock.name,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                FormatUtils.currency(summary.stock.currentPrice, showSymbol: false),
                style: AppTypography.displayLarge.copyWith(
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: summary.isPositive
                      ? const Color.fromRGBO(52, 211, 153, 0.1)
                      : const Color.fromRGBO(239, 68, 68, 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${summary.isPositive ? "▲" : "▼"} ${FormatUtils.percentage(summary.gainLossPercent, showSign: true)}',
                  style: AppTypography.titleSmall.copyWith(
                    color: summary.isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Terakhir diperbarui: ${FormatUtils.date(summary.stock.lastUpdated, format: "HH:mm")} WIB',
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics(StockSummary summary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Lots',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.totalLots}',
                    style: AppTypography.titleLarge.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Avg Price',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    FormatUtils.currency(summary.averagePrice, showSymbol: false),
                    style: AppTypography.titleLarge.copyWith(
                      color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    final lineColor = AppColors.primary;
    final gradientColors = [
      AppColors.primary.withValues(alpha: 0.3),
      AppColors.primary.withValues(alpha: 0.0),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price History',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRangeButton('1d', isDark),
                        _buildRangeButton('1w', isDark),
                        _buildRangeButton('1mo', isDark),
                        _buildRangeButton('3mo', isDark),
                        _buildRangeButton('6mo', isDark),
                        _buildRangeButton('1y', isDark),
                        _buildRangeButton('3y', isDark),
                        _buildRangeButton('5y', isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_priceHistory.isEmpty)
              SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No price data available',
                    style: TextStyle(
                      color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: _calculateGridInterval(),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: isDark ? AppColors.cardBorder : AppColors.lightCardBorder,
                        strokeWidth: 0.5,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: _calculateGridInterval(),
                          getTitlesWidget: (value, meta) {
                            return Text(
                              FormatUtils.currencyShort(value),
                              style: AppTypography.labelSmall.copyWith(
                                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: (_priceHistory.length / 4).ceil().toDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _priceHistory.length) {
                              final date = _priceHistory[index]['date'] as DateTime;
                              return Text(
                                '${date.day}/${date.month}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _priceHistory.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value['price'] as double);
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.2,
                        color: lineColor,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                    minX: 0,
                    maxX: (_priceHistory.length - 1).toDouble(),
                    minY: _priceHistory.map((e) => e['price'] as double).reduce((a, b) => a < b ? a : b) * 0.98,
                    maxY: _priceHistory.map((e) => e['price'] as double).reduce((a, b) => a > b ? a : b) * 1.02,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeButton(String apiRange, bool isDark) {
    final isSelected = apiRange == _selectedRange;
    final displayLabel = _rangeDisplayMap[apiRange] ?? apiRange;
    return GestureDetector(
      onTap: () => _changeRange(apiRange),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          displayLabel,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  double _calculateGridInterval() {
    if (_priceHistory.isEmpty) return 1000;
    final prices = _priceHistory.map((e) => e['price'] as double).toList();
    final min = prices.reduce((a, b) => a < b ? a : b);
    final max = prices.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range < 100) return 50;
    if (range < 500) return 100;
    if (range < 1000) return 200;
    if (range < 5000) return 1000;
    return 2000;
  }

  Widget _buildBEPCard(StockSummary summary, bool isDark) {
    final remaining = summary.totalInvested - summary.dividendsReceived;

    return GlassCard(
      child: Column(
        children: [
          Text(
            'BEP Progress',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          BEPCircularProgress(
            percentage: summary.bepProgress,
            covered: FormatUtils.currencyShort(summary.dividendsReceived),
            remaining: FormatUtils.currencyShort(remaining > 0 ? remaining : 0),
          ),
          const SizedBox(height: 12),
          Text(
            'Modal: ${FormatUtils.currency(summary.totalInvested)} • Est. BEP: Q3 2026',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDividendHistory(List<DividendRecord> dividends, bool isDark) {
    if (dividends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          'No dividend history',
          style: TextStyle(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: dividends.length,
      itemBuilder: (context, index) {
        final dividend = dividends[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dividend.exDate.year} - ${dividend.exDate.month <= 6 ? "Final" : "Interim"}',
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ex: ${FormatUtils.date(dividend.exDate)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${FormatUtils.currency(dividend.dividendPerLot, showSymbol: false)}/lot',
                      style: AppTypography.titleSmall.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Badge(
                      label: dividend.dividendType == DividendType.reinvest
                          ? 'Reinvested'
                          : 'Cash Out',
                      isReinvest: dividend.dividendType == DividendType.reinvest,
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

  Widget _buildBuyHistory(List<PortfolioEntry> entries, bool isDark) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          'No buy history',
          style: TextStyle(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return GestureDetector(
          onTap: () => AppRouter.push(
            context,
            AppRoutes.editTransaction,
            arguments: entry,
          ).then((_) => _loadData()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatUtils.date(entry.buyDate),
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.lots} lot @ ${FormatUtils.currency(entry.pricePerLot, showSymbol: false)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.currencyShort(entry.totalCost),
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (entry.isReinvested) ...[
                        const SizedBox(height: 4),
                        const Badge(label: 'Reinvest', isReinvest: true),
                      ],
                    ],
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
