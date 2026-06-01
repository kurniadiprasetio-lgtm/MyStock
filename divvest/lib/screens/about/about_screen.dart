import 'package:flutter/material.dart';
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
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'DV',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
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
          'DivVest adalah aplikasi mobile untuk tracking portofolio saham Indonesia dengan fokus pada dividend investing & reinvestment (DRIP). Aplikasi ini membantu investor dividen untuk memantau Break Even Point (BEP), Yield on Cost, dan proyeksi passive income dari dividen yang diterima.',
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
      (Icons.account_balance_wallet_outlined, 'Portfolio Management', 'Input pembelian saham, tracking lot, averaging price'),
      (Icons.payments_outlined, 'Dividend Tracking', 'Catat dividen cash out & reinvested (DRIP)'),
      (Icons.speed_outlined, 'BEP Progress', 'Monitor break-even point via dividen'),
      (Icons.calendar_month_outlined, 'Dividend Calendar', 'Jadwal ex-date & payment date per bulan'),
      (Icons.autorenew_outlined, 'Auto Reinvestment', 'Otomatis buat entry baru dari dividen'),
      (Icons.show_chart_outlined, 'Price History', 'Chart harga real-time dari Yahoo Finance'),
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
            Icon(Icons.info_outline, size: 24, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              'Data harga saham bersumber dari Yahoo Finance dan mungkin tidak real-time. Aplikasi ini tidak menyediakan saran investasi. Semua keputusan investasi adalah tanggung jawab pengguna.',
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
