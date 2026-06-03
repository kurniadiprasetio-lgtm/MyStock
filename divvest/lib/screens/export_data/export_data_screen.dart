import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../widgets/components/components.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  final _repository = PortfolioRepository();
  bool _isExporting = false;
  String _exportStatus = '';

  Future<void> _exportAll() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Generating CSV...';
    });

    try {
      final entries = await _repository.getEntries();
      final dividends = await _repository.getDividends();
      final summaries = await _repository.getAllStockSummaries();

      final csvContent = _generateCSV(entries, dividends, summaries);
      final filePath = await _saveCSV(csvContent);

      if (filePath != null) {
        setState(() => _exportStatus = 'Sharing file...');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            text: 'DivVest Portfolio Export',
          ),
        );
        setState(() => _exportStatus = 'Export complete!');
      }
    } catch (e) {
      setState(() => _exportStatus = 'Error: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _generateCSV(
    List<PortfolioEntry> entries,
    List<DividendRecord> dividends,
    List<StockSummary> summaries,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('=== DIVVEST PORTFOLIO EXPORT ===');
    buffer.writeln('Export Date: ${DateTime.now().toString()}');
    buffer.writeln('');

    buffer.writeln('=== PORTFOLIO ENTRIES ===');
    buffer.writeln('Ticker,Buy Date,Lots,Price/Lot,Fee,Total Cost,Is Reinvested,Notes');
    for (final entry in entries) {
      buffer.writeln(
        '${entry.ticker},'
        '${entry.buyDate.toString().split(' ')[0]},'
        '${entry.lots},'
        '${entry.pricePerLot.toStringAsFixed(0)},'
        '${entry.fee.toStringAsFixed(0)},'
        '${entry.totalCost.toStringAsFixed(0)},'
        '${entry.isReinvested ? 'Yes' : 'No'},'
        '"${entry.notes ?? ''}"',
      );
    }
    buffer.writeln('');

    buffer.writeln('=== DIVIDEND RECORDS ===');
    buffer.writeln('Ticker,Ex Date,Pay Date,Div/Lot,Lots Held,Gross,Tax Rate,Net,Type');
    for (final d in dividends) {
      buffer.writeln(
        '${d.ticker},'
        '${d.exDate.toString().split(' ')[0]},'
        '${d.paymentDate.toString().split(' ')[0]},'
        '${d.dividendPerLot.toStringAsFixed(0)},'
        '${d.lotsHeldAtExDate},'
        '${d.grossAmount.toStringAsFixed(0)},'
        '${(d.taxRate * 100).toStringAsFixed(0)}%,'
        '${d.netAmount.toStringAsFixed(0)},'
        '${d.dividendType.name}',
      );
    }
    buffer.writeln('');

    buffer.writeln('=== STOCK SUMMARY ===');
    buffer.writeln('Ticker,Total Lots,Avg Price,Current Price,Total Invested,Current Value,Gain/Loss,Dividends Received');
    for (final s in summaries) {
      final gainLoss = s.currentValue - s.totalInvested;
      buffer.writeln(
        '${s.stock.ticker},'
        '${s.totalLots},'
        '${s.averagePrice.toStringAsFixed(0)},'
        '${s.stock.currentPrice.toStringAsFixed(0)},'
        '${s.totalInvested.toStringAsFixed(0)},'
        '${s.currentValue.toStringAsFixed(0)},'
        '${gainLoss.toStringAsFixed(0)},'
        '${s.dividendsReceived.toStringAsFixed(0)}',
      );
    }

    return buffer.toString();
  }

  Future<String?> _saveCSV(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'divvest_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(content);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Export Data',
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildInfoCard(isDark),
              _buildExportButton(isDark),
              if (_exportStatus.isNotEmpty) _buildStatusText(isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Platform.isIOS ? CupertinoIcons.info_circle : Icons.info_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Export Information',
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Portfolio Entries', 'Buy transactions & reinvestments', isDark),
            _buildInfoItem('Dividend Records', 'All dividend payments received', isDark),
            _buildInfoItem('Stock Summary', 'Current holdings & performance', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Platform.isIOS ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle,
            color: AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: AppButton(
        label: 'Export & Share',
        icon: Icon(
          Platform.isIOS ? CupertinoIcons.square_arrow_up : Icons.share,
          size: 20,
        ),
        onPressed: _isExporting ? null : _exportAll,
      ),
    );
  }

  Widget _buildStatusText(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _exportStatus,
        style: AppTypography.bodySmall.copyWith(
          color: _exportStatus.startsWith('Error') ? AppColors.error : AppColors.success,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
