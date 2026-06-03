import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../providers/portfolio_provider.dart';
import '../../routes/app_router.dart';
import '../../widgets/components/components.dart';
import '../../widgets/dividend_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  List<DividendRecord> _allDividends = [];
  bool _isLoading = true;
  final _repository = PortfolioRepository();

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

    final allDividends = await provider.getAllDividends();
    final now = DateTime.now();
    
    final enriched = <DividendRecord>[];
    for (final d in allDividends) {
      debugPrint('[Calendar] Processing ${d.ticker} on ${d.exDate.toIso8601String()}, lotsHeldAtExDate=${d.lotsHeldAtExDate}');
      if (d.lotsHeldAtExDate == 0) {
        var lots = await _repository.getLotsHeldAtDate(d.ticker, d.exDate);
        debugPrint('[Calendar] Historical lots for ${d.ticker}: $lots');
        
        if (lots == 0) {
          lots = await _repository.getCurrentLots(d.ticker);
          debugPrint('[Calendar] Fallback to current lots for ${d.ticker}: $lots');
        }
        
        if (lots > 0) {
          await _repository.updateLotsHeldAtExDate(d.ticker, d.exDate, lots);
          enriched.add(d.copyWith(lotsHeldAtExDate: lots));
          debugPrint('[Calendar] Updated ${d.ticker} in DB with lots=$lots');
        } else {
          enriched.add(d);
        }
      } else {
        enriched.add(d);
      }
    }
    
    final upcoming = enriched.where((d) => d.exDate.isAfter(now)).toList();
    final past = enriched.where((d) => !d.exDate.isAfter(now)).toList();
    
    upcoming.sort((a, b) => a.exDate.compareTo(b.exDate));
    past.sort((a, b) => b.exDate.compareTo(a.exDate));
    
    final sorted = <DividendRecord>[];
    sorted.addAll(upcoming);
    sorted.addAll(past);

    if (mounted) {
      setState(() {
        _allDividends = sorted;
        _isLoading = false;
      });
    }
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
          icon: Platform.isIOS ? CupertinoIcons.add : Icons.add,
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addDividend),
        ),
        AppIconButton(
          icon: Platform.isIOS ? CupertinoIcons.refresh : Icons.sync,
          onPressed: () async {
            await context.read<PortfolioProvider>().syncAllDividends();
            if (mounted) {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dividends synced')),
              );
            }
          },
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
                      child: _allDividends.isEmpty
                          ? _buildEmptyState(isDark)
                          : _buildDividendList(isDark),
                    ),
                  ),
                  _buildSummary(isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildDividendList(bool isDark) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: double.infinity),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: _allDividends.length,
        itemBuilder: (context, index) {
          final dividend = _allDividends[index];
          return DividendCard(
            dividend: dividend,
            showNetAmount: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_month_outlined,
              size: 64,
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No dividends found',
              style: AppTypography.titleSmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap sync to fetch from Yahoo Finance',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    final totalDividends = _allDividends.fold<double>(0, (sum, d) => sum + d.netAmount);
    final upcomingCount = _allDividends.where((d) => d.exDate.isAfter(DateTime.now())).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondary : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem(
            'Total Received',
            FormatUtils.currencyShort(totalDividends),
            isDark,
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.1) : AppColors.lightCardBorder,
          ),
          _buildSummaryItem(
            'Upcoming',
            '$upcomingCount',
            isDark,
            valueColor: AppColors.warning,
          ),
          Container(
            width: 1,
            height: 32,
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.1) : AppColors.lightCardBorder,
          ),
          _buildSummaryItem(
            'Total Records',
            '${_allDividends.length}',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, bool isDark, {Color? valueColor}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleSmall.copyWith(
              color: valueColor ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
