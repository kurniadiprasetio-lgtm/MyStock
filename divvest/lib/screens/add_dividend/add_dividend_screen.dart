import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/components/components.dart';

class AddDividendScreen extends StatefulWidget {
  const AddDividendScreen({super.key});

  @override
  State<AddDividendScreen> createState() => _AddDividendScreenState();
}

class _AddDividendScreenState extends State<AddDividendScreen> {
  String? _selectedTicker;
  List<Stock> _stocks = [];
  List<Stock> _filteredStocks = [];
  DateTime _exDate = DateTime.now();
  DateTime _paymentDate = DateTime.now().add(const Duration(days: 14));
  final _netAmountController = TextEditingController();
  final _reinvestPriceController = TextEditingController();
  final _stockSearchController = TextEditingController();
  final _stockFocusNode = FocusNode();
  final _stockOverlayLink = LayerLink();
  bool _isLoading = false;
  bool _showStockDropdown = false;

  double get netAmount => double.tryParse(_netAmountController.text) ?? 0;

  int get reinvestLots {
    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) return 0;
    return (netAmount ~/ (price * 100)).toInt();
  }

  double get reinvestRemainder {
    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) return 0;
    return netAmount % (price * 100);
  }

  @override
  void initState() {
    super.initState();
    _stockFocusNode.addListener(_onStockFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStocks());
  }

  void _onStockFocusChange() {
    if (!_stockFocusNode.hasFocus) {
      setState(() => _showStockDropdown = false);
    }
  }

  void _filterStocks(String query) {
    final q = query.toUpperCase();
    setState(() {
      if (q.isEmpty) {
        _filteredStocks = _stocks;
        _showStockDropdown = _stocks.isNotEmpty;
      } else {
        _filteredStocks = _stocks.where((s) {
          return s.ticker.toUpperCase().contains(q) ||
              s.name.toUpperCase().contains(q);
        }).toList();
        _showStockDropdown = _filteredStocks.isNotEmpty;
      }

      final exactMatch = _filteredStocks.where((s) => s.ticker.toUpperCase() == q).toList();
      if (exactMatch.length == 1) {
        _selectedTicker = exactMatch.first.ticker;
      }
    });
  }

  void _selectStock(Stock stock) {
    setState(() {
      _selectedTicker = stock.ticker;
      _stockSearchController.text = '${stock.ticker} - ${stock.name}';
      _showStockDropdown = false;
      _stockFocusNode.unfocus();
    });
  }

  Future<void> _loadStocks() async {
    final provider = context.read<PortfolioProvider>();
    await provider.loadPortfolio();
    final stocks = await provider.getAllStocks();
    if (mounted) {
      setState(() {
        _stocks = stocks;
        _filteredStocks = stocks;
        if (_stocks.isNotEmpty) {
          _selectedTicker = _stocks.first.ticker;
          _stockSearchController.text = '${_stocks.first.ticker} - ${_stocks.first.name}';
        }
      });
    }
  }

  Future<void> _save() async {
    if (_selectedTicker == null) {
      AppSnackBar.showError(context, 'Please select a stock');
      return;
    }

    if (netAmount <= 0) {
      AppSnackBar.showError(context, 'Please enter net dividend amount');
      return;
    }

    final price = double.tryParse(_reinvestPriceController.text) ?? 0;
    if (price <= 0) {
      AppSnackBar.showError(context, 'Please enter reinvest price');
      return;
    }

    setState(() => _isLoading = true);

    final dps = netAmount / 100;
    final lots = reinvestLots;
    debugPrint('[AddDividend] Net: $netAmount, Price: $price, Lots: $lots');

    final record = DividendRecord(
      ticker: _selectedTicker!,
      exDate: _exDate,
      paymentDate: _paymentDate,
      dividendPerLot: dps,
      dividendType: DividendType.reinvest,
      lotsHeldAtExDate: 1,
      taxRate: 0,
    );

    await context.read<PortfolioProvider>().addDividend(record);

    final entry = PortfolioEntry(
      ticker: _selectedTicker!,
      buyDate: _paymentDate,
      lots: reinvestLots,
      pricePerLot: price,
      fee: 0,
      isReinvested: true,
      notes: 'Auto reinvest from dividend',
    );
    await context.read<PortfolioProvider>().addEntry(entry);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, 'Dividend & reinvestment saved');
    }
  }

  @override
  void dispose() {
    _stockFocusNode.removeListener(_onStockFocusChange);
    _stockFocusNode.dispose();
    _stockSearchController.dispose();
    _netAmountController.dispose();
    _reinvestPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Add Dividend',
      body: AppLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildStockField(isDark),
                    _buildDates(isDark),
                    _buildNetAmountField(),
                    _buildReinvestPriceField(),
                    _buildCalculationCard(isDark),
                    const SizedBox(height: 8),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              _buildStockDropdown(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CompositedTransformTarget(
            link: _stockOverlayLink,
            child: AppTextField(
              label: '',
              controller: _stockSearchController,
              focusNode: _stockFocusNode,
              hintText: 'Search stock...',
              suffixIcon: const Icon(Icons.arrow_drop_down, size: 24),
              onTap: () {
                setState(() => _showStockDropdown = true);
              },
              onChanged: _filterStocks,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockDropdown(bool isDark) {
    if (!_showStockDropdown || _filteredStocks.isEmpty) return const SizedBox.shrink();

    return CompositedTransformFollower(
      link: _stockOverlayLink,
      targetAnchor: Alignment.bottomLeft,
      followerAnchor: Alignment.topLeft,
      offset: const Offset(0, 4),
      showWhenUnlinked: false,
      child: Material(
        elevation: 8,
        color: isDark ? AppColors.backgroundSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 240),
          width: MediaQuery.of(context).size.width - 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
              width: 1,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _filteredStocks.length > 5 ? 5 : _filteredStocks.length,
            itemBuilder: (context, index) {
              final stock = _filteredStocks[index];
              final isSelected = stock.ticker == _selectedTicker;
              return ListTile(
                dense: true,
                title: Text(
                  '${stock.ticker} - ${stock.name}',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => _selectStock(stock),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDates(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: AppDateField(
              label: 'Ex-Date',
              controller: TextEditingController(text: FormatUtils.date(_exDate)),
              initialDate: _exDate,
              onDateSelected: (date) => setState(() => _exDate = date),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppDateField(
              label: 'Payment Date',
              controller: TextEditingController(text: FormatUtils.date(_paymentDate)),
              initialDate: _paymentDate,
              onDateSelected: (date) => setState(() => _paymentDate = date),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetAmountField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppCurrencyField(
        label: 'Net Dividend Received (IDR)',
        controller: _netAmountController,
        hintText: 'e.g., 813600',
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildReinvestPriceField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppCurrencyField(
        label: 'Reinvest Price per Lot (IDR)',
        controller: _reinvestPriceController,
        hintText: 'e.g., 5700',
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
            _buildCalcRow('Net Dividend', FormatUtils.currency(netAmount), isDark, isTotal: true, valueColor: AppColors.success),
            const SizedBox(height: 14),
            Container(height: 1, color: isDark ? const Color.fromRGBO(255, 255, 255, 0.08) : AppColors.lightCardBorder),
            const SizedBox(height: 14),
            Text('Auto Reinvest', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
            const SizedBox(height: 6),
            Text(
              '$reinvestLots lot${reinvestLots != 1 ? 's' : ''} (sisa: ${FormatUtils.currency(reinvestRemainder, showSymbol: false)})',
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

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AppButton(
        label: 'Save Dividend & Reinvest',
        onPressed: _save,
      ),
    );
  }
}
