import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../data/repositories/portfolio_repository.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/components/components.dart';
import '../../widgets/dividend_card.dart';

class AddDividendScreen extends StatefulWidget {
  const AddDividendScreen({super.key});

  @override
  State<AddDividendScreen> createState() => _AddDividendScreenState();
}

class _AddDividendScreenState extends State<AddDividendScreen> {
  List<DividendRecord> _dividends = [];
  DividendRecord? _selectedDividend;
  final _reinvestPriceController = TextEditingController();
  bool _isLoading = false;
  final _repository = PortfolioRepository();

  int get _lotsHeld => _selectedDividend?.lotsHeldAtExDate ?? 0;

  double get _dividendPerLot => _selectedDividend?.dividendPerLot ?? 0;

  double get _netAmount => _lotsHeld * _dividendPerLot * 100;

  int get _reinvestLots {
    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) return 0;
    return (_netAmount ~/ (price * 100)).toInt();
  }

  double get _reinvestRemainder {
    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) return 0;
    return _netAmount % (price * 100);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDividends());
  }

  Future<void> _loadDividends() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final provider = context.read<PortfolioProvider>();
    final allDividends = await provider.getAllDividends();
    final now = DateTime.now();
    
    final pastDividends = allDividends
        .where((d) => d.exDate.isBefore(now))
        .toList();
    
    pastDividends.sort((a, b) => b.exDate.compareTo(a.exDate));

    final enriched = <DividendRecord>[];
    for (final d in pastDividends) {
      if (d.lotsHeldAtExDate == 0) {
        final currentLots = await _repository.getLotsHeldAtDate(d.ticker, d.exDate);
        if (currentLots > 0) {
          enriched.add(d.copyWith(lotsHeldAtExDate: currentLots));
        } else {
          enriched.add(d);
        }
      } else {
        enriched.add(d);
      }
    }

    if (mounted) {
      setState(() {
        _dividends = enriched;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDividend(DividendRecord dividend) async {
    if (dividend.lotsHeldAtExDate == 0) {
      final currentLots = await _repository.getLotsHeldAtDate(dividend.ticker, dividend.exDate);
      if (currentLots > 0) {
        dividend = dividend.copyWith(lotsHeldAtExDate: currentLots);
      }
    }

    setState(() {
      _selectedDividend = dividend;
    });
  }

  Future<void> _save() async {
    if (_selectedDividend == null) {
      AppSnackBar.showError(context, 'Please select a dividend');
      return;
    }

    if (_lotsHeld <= 0) {
      AppSnackBar.showError(context, 'No lots held for this dividend');
      return;
    }

    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) {
      AppSnackBar.showError(context, 'Please enter reinvest price');
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<PortfolioProvider>();

    final reinvestEntry = PortfolioEntry(
      ticker: _selectedDividend!.ticker,
      buyDate: _selectedDividend!.paymentDate,
      lots: _reinvestLots,
      pricePerLot: price,
      fee: 0,
      isReinvested: true,
      sourceDividendId: _selectedDividend!.id,
      notes: 'Reinvest from dividend',
    );
    final savedEntry = await provider.addEntry(reinvestEntry);

    await provider.updateDividend(_selectedDividend!.copyWith(
      dividendType: DividendType.reinvest,
      reinvestEntryId: savedEntry.id,
    ));

    debugPrint('[AddDividend] Reinvested $_reinvestLots lots from dividend ${_selectedDividend!.id}, entry=${savedEntry.id}');

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, 'Reinvestment saved');
    }
  }

  @override
  void dispose() {
    _reinvestPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Reinvest Dividend',
      body: AppLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildDividendSelector(isDark),
                      _buildSelectedDividendInfo(isDark),
                      _buildReinvestPriceField(),
                      _buildCalculationCard(isDark),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividendSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Dividend',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_dividends.isEmpty)
            _buildEmptyDividends(isDark)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: _dividends.length,
                itemBuilder: (context, index) {
                  final dividend = _dividends[index];
                  final isSelected = _selectedDividend?.id == dividend.id;
                  return GestureDetector(
                    onTap: () => _selectDividend(dividend),
                    child: Stack(
                      children: [
                        DividendCard(dividend: dividend, showNetAmount: true),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (isSelected)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Icon(
                              Platform.isIOS ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyDividends(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Platform.isIOS ? CupertinoIcons.info_circle : Icons.info_outline,
            size: 40,
            color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No dividends found',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap sync button in Calendar first',
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDividendInfo(bool isDark) {
    final lotsHeld = _selectedDividend?.lotsHeldAtExDate ?? 0;
    final dps = _selectedDividend?.dividendPerLot ?? 0;
    final ticker = _selectedDividend?.ticker ?? '-';
    final exDate = _selectedDividend != null ? FormatUtils.dateShort(_selectedDividend!.exDate) : '-';
    final payDate = _selectedDividend != null ? FormatUtils.dateShort(_selectedDividend!.paymentDate) : '-';
    final gross = lotsHeld > 0 ? (lotsHeld * 100 * dps).toDouble() : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Dividend',
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Ticker', ticker, isDark),
            _buildInfoRow('Ex-Date', exDate, isDark),
            _buildInfoRow('Pay Date', payDate, isDark),
            _buildInfoRow('Div/Lot', FormatUtils.currency(dps, showSymbol: false), isDark),
            _buildInfoRow('Lots Held', lotsHeld > 0 ? lotsHeld.toString() : '-', isDark),
            _buildInfoRow('Net', lotsHeld > 0 ? FormatUtils.currency(gross, showSymbol: false) : '-', isDark, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: isTotal ? AppColors.success : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReinvestPriceField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: AppCurrencyField(
        label: 'Reinvest Price per Lot (IDR)',
        controller: _reinvestPriceController,
        hintText: 'e.g., 10250',
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildCalculationCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCalcRow('Net Dividend', FormatUtils.currency(_netAmount), isDark, isTotal: true, valueColor: AppColors.success),
            const SizedBox(height: 14),
            Container(height: 1, color: isDark ? const Color.fromRGBO(255, 255, 255, 0.08) : AppColors.lightCardBorder),
            const SizedBox(height: 14),
            Text('Reinvest Lots', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
            const SizedBox(height: 6),
            Text(
              '$_reinvestLots lot${_reinvestLots != 1 ? 's' : ''} (rem: ${FormatUtils.currency(_reinvestRemainder, showSymbol: false)})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? AppColors.primaryLight : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcRow(String label, String value, bool isDark, {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500, color: isTotal ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary) : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary))),
        Text(value, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700, color: valueColor ?? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary))),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundSecondary : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        label: 'Save Reinvestment',
        onPressed: _save,
      ),
    );
  }
}
