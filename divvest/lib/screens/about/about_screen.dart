import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/components/components.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'About',
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(isDark),
              _buildDescription(isDark),
              _buildSectionTitle('Key Features', isDark),
              _buildFeatureList(isDark),
              _buildSectionTitle('Disclaimer', isDark),
              _buildDisclaimer(isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/icon/app_icon.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'DivVest',
            style: AppTypography.displayLarge.copyWith(
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dividend Reinvestment Tracker',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        child: Text(
          'DivVest is a mobile application for tracking the Indonesian stock portfolio with a focus on dividend investing & reinvestment (DRIP). This application helps dividend investors to monitor Break Even Point (BEP), Yield on Cost, and projected passive income from received dividends.',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  Widget _buildFeatureList(bool isDark) {
    final features = [
      (Platform.isIOS ? CupertinoIcons.creditcard : Icons.account_balance_wallet_outlined, 'Portfolio Management', 'Input stock purchase, tracking lots, averaging price'),
      (Platform.isIOS ? CupertinoIcons.money_dollar : Icons.payments_outlined, 'Dividend Tracking', 'Record cash out & reinvested dividends (DRIP)'),
      (Platform.isIOS ? CupertinoIcons.speedometer : Icons.speed_outlined, 'BEP Progress', 'Monitor break-even point via dividends'),
      (Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_month_outlined, 'Dividend Calendar', 'Ex-date & payment date schedules per month'),
      (Platform.isIOS ? CupertinoIcons.arrow_2_squarepath : Icons.autorenew_outlined, 'Auto Reinvestment', 'Automatically create new entry from dividend'),
      (Platform.isIOS ? CupertinoIcons.chart_bar : Icons.show_chart_outlined, 'Price History', 'Real-time price chart from Yahoo Finance'),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(99, 102, 241, 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromRGBO(99, 102, 241, 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(feature.$1, size: 22, color: const Color(0xFF6366f1)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.$2,
                        style: AppTypography.titleSmall.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature.$3,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimer(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        child: Column(
          children: [
            Icon(Platform.isIOS ? CupertinoIcons.info : Icons.info_outline, size: 24, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              'Stock price data is sourced from Yahoo Finance and may not be real-time. This application does not provide investment advice. All investment decisions are the user\'s responsibility.',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
