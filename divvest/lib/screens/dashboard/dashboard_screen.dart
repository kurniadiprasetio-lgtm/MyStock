import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/components/components.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<PortfolioProvider>().loadPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'DivVest',
      showBackButton: false,
      actions: [
        const AppIconButton(icon: Icons.notifications_outlined),
        const SizedBox(width: 8),
        const AppIconButton(icon: Icons.settings_outlined),
      ],
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final summary = provider.portfolioSummary;
          if (summary == null) return const SizedBox.shrink();

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<PortfolioProvider>().refreshOwnedPrices();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(isDark),
                  _buildPortfolioCard(summary, isDark),
                  _buildBEPCard(summary, isDark),
                  _buildQuickStats(provider, isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGreeting(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Portfolio Overview',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioSummary summary, bool isDark) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio',
            style: AppTypography.labelSmall.copyWith(
              color: const Color.fromRGBO(255, 255, 255, 0.85),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FormatUtils.currency(summary.currentValue),
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildSummaryItem(
                'Invested',
                FormatUtils.currencyShort(summary.totalInvested),
              ),
              const SizedBox(width: 10),
              _buildSummaryItem(
                'Current',
                FormatUtils.currencyShort(summary.currentValue),
              ),
              const SizedBox(width: 10),
              _buildSummaryItem(
                'Gain',
                FormatUtils.percentage(summary.gainLossPercent, showSign: true),
                isPositive: summary.isProfitable,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isPositive = true}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBEPCard(PortfolioSummary summary, bool isDark) {
    final bepProgress = summary.totalInvested > 0
        ? (summary.totalDividendsReceived / summary.totalInvested * 100).clamp(0.0, 100.0).toDouble()
        : 0.0;
    final remaining = summary.totalInvested - summary.totalDividendsReceived;

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
          BEPProgressBar(
            percentage: bepProgress,
            covered: FormatUtils.currencyShort(summary.totalDividendsReceived),
            remaining: FormatUtils.currencyShort(remaining > 0 ? remaining : 0),
          ),
          const SizedBox(height: 12),
          Text(
            'Modal tercover via dividen • Est. BEP: Q3 2026',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(PortfolioProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.payments_outlined,
              iconColor: AppColors.success,
              label: 'Monthly Income',
              value: FormatUtils.currencyShort(provider.monthlyIncome),
              change: '↑ 12% vs last month',
              changePositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.trending_up_outlined,
              iconColor: AppColors.primary,
              label: 'Yield on Cost',
              value: FormatUtils.percentage(provider.yieldOnCost),
              change: '↑ 0.3% vs last year',
              changePositive: true,
            ),
          ),
        ],
      ),
    );
  }
}
