import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../routes/app_router.dart';
import '../../widgets/components/components.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadPortfolio();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PortfolioProvider>().loadPortfolio();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Portfolio',
      showBackButton: false,
      actions: [
        AppIconButton(icon: Platform.isIOS ? CupertinoIcons.search : Icons.search_outlined),
        const SizedBox(width: 8),
        AppIconButton(
          icon: Platform.isIOS ? CupertinoIcons.add : Icons.add,
          onPressed: () => AppRouter.push(context, AppRoutes.addTransaction).then((_) {
            if (context.mounted) {
              context.read<PortfolioProvider>().loadPortfolio();
            }
          }),
        ),
      ],
      body: SafeArea(
        child: Consumer<PortfolioProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            final summaries = provider.stockSummaries;

            if (summaries.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<PortfolioProvider>().refreshPrices();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Text(
                        'No portfolio entries yet',
                        style: TextStyle(color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<PortfolioProvider>().refreshOwnedPrices();
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                itemCount: summaries.length,
                itemBuilder: (context, index) {
                  final summary = summaries[index];
                  return _buildStockCard(context, summary, isDark);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStockCard(BuildContext context, StockSummary summary, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: () => AppRouter.push(
          context,
          '${AppRoutes.stockDetail}?ticker=${summary.stock.ticker}',
        ),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  StockLogo(ticker: summary.stock.ticker, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.stock.ticker,
                          style: AppTypography.titleMedium.copyWith(
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
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
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.currency(summary.stock.currentPrice, showSymbol: false),
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: summary.isPositive
                              ? const Color.fromRGBO(16, 185, 129, 0.12)
                              : const Color.fromRGBO(239, 68, 68, 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: summary.isPositive
                                ? const Color.fromRGBO(16, 185, 129, 0.3)
                                : const Color.fromRGBO(239, 68, 68, 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${summary.isPositive ? "▲" : "▼"} ${FormatUtils.percentage(summary.gainLossPercent, showSign: true)}',
                          style: AppTypography.labelMedium.copyWith(
                            color: summary.isPositive ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
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
                children: [
                  _buildMetric('Lots', '${summary.totalLots}', isDark),
                  const SizedBox(width: 10),
                  _buildMetric('Avg', FormatUtils.currency(summary.averagePrice, showSymbol: false), isDark),
                  const SizedBox(width: 10),
                  _buildMetric(
                    'BEP',
                    '${summary.bepProgress.toStringAsFixed(0)}%',
                    isDark,
                    color: summary.bepProgress >= 80
                        ? AppColors.success
                        : summary.bepProgress >= 50
                            ? AppColors.warning
                            : AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color.fromRGBO(255, 255, 255, 0.03) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color.fromRGBO(255, 255, 255, 0.05) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Column(
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
        ),
      ),
    );
  }
}
