import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/components/components.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool isBuy = true;
  bool isReinvest = false;
  String? _selectedTicker;
  final _dateController = TextEditingController();
  final _lotsController = TextEditingController();
  final _priceController = TextEditingController();
  final _feeController = TextEditingController();
  final _notesController = TextEditingController();
  final _stockSearchController = TextEditingController();
  final _stockFocusNode = FocusNode();
  final _stockOverlayLink = LayerLink();
  bool _isLoading = false;
  bool _isReloading = false;
  bool _showStockDropdown = false;
  List<Stock> _stocks = [];
  List<Stock> _filteredStocks = [];
  List<DividendRecord> _availableDividends = [];
  int? _selectedDividendId;

  @override
  void initState() {
    super.initState();
    _dateController.text = FormatUtils.date(DateTime.now());
    _stockFocusNode.addListener(_onStockFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStocks();
    });
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
    _loadDividendsForTicker(stock.ticker);
  }

  Future<void> _loadDividendsForTicker(String ticker) async {
    final provider = context.read<PortfolioProvider>();
    final dividends = await provider.getAllDividends();
    final tickerDividends = dividends.where((d) => d.ticker == ticker).toList();
    if (mounted) {
      setState(() {
        _availableDividends = tickerDividends;
        _selectedDividendId = null;
      });
    }
  }

  Future<void> _loadStocks() async {
    final provider = context.read<PortfolioProvider>();
    final stocks = await provider.getAllStocks();
    if (mounted) {
      setState(() {
        _stocks = stocks;
        _filteredStocks = stocks;
        if (_stocks.isNotEmpty && _selectedTicker == null) {
          _selectedTicker = _stocks.first.ticker;
          _stockSearchController.text = '${_stocks.first.ticker} - ${_stocks.first.name}';
        }
      });
    }
  }

  Future<void> _reloadStocks() async {
    setState(() => _isReloading = true);
    final provider = context.read<PortfolioProvider>();
    final count = await provider.refreshStockList();
    if (mounted) {
      setState(() => _isReloading = false);
      await _loadStocks();
      AppSnackBar.showSuccess(context, '$count stocks updated');
    }
  }

  double get total {
    final lots = int.tryParse(_lotsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final fee = double.tryParse(_feeController.text) ?? 0;
    return (lots * 100 * price) + fee;
  }

  @override
  void dispose() {
    _stockFocusNode.removeListener(_onStockFocusChange);
    _stockFocusNode.dispose();
    _stockSearchController.dispose();
    _dateController.dispose();
    _lotsController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = FormatUtils.date(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_selectedTicker == null) {
      AppSnackBar.showError(context, 'Please select a stock');
      return;
    }

    final lots = int.tryParse(_lotsController.text);
    final price = double.tryParse(_priceController.text);
    final fee = double.tryParse(_feeController.text) ?? 0;

    if (lots == null || price == null || lots <= 0 || price <= 0) {
      AppSnackBar.showError(context, 'Please fill in valid Lots and Price');
      return;
    }

    setState(() => _isLoading = true);

    final entry = PortfolioEntry(
      ticker: _selectedTicker!,
      buyDate: DateTime.now(),
      lots: lots,
      pricePerLot: price,
      fee: fee,
      isReinvested: isReinvest,
      sourceDividendId: isReinvest ? _selectedDividendId : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await context.read<PortfolioProvider>().addEntry(entry);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, 'Transaction saved successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Add Transaction',
      body: AppLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildToggle(isDark),
                    _buildStockField(isDark),
                    if (isBuy && isReinvest) _buildDividendSelector(isDark),
                    _buildDateField(),
                    _buildLotsAndPrice(isDark),
                    _buildFeeField(),
                    _buildTotalBox(isDark),
                    _buildNotesField(),
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

  Widget _buildToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          AppToggle<bool>(
            items: const [
              AppToggleItem(value: true, label: '📥 Buy'),
              AppToggleItem(value: false, label: '📤 Sell'),
            ],
            selectedValue: isBuy,
            onChanged: (value) => setState(() {
              isBuy = value;
              if (value) {
                isReinvest = false;
              }
            }),
          ),
          if (isBuy) ...[
            const SizedBox(height: 8),
            AppToggle<bool>(
              items: const [
                AppToggleItem(value: false, label: 'Regular Buy'),
                AppToggleItem(value: true, label: '🔄 Reinvestment'),
              ],
              selectedValue: isReinvest,
              onChanged: (value) => setState(() => isReinvest = value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stock',
                style: AppTypography.labelMedium.copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                ),
              ),
              GestureDetector(
                onTap: _isReloading ? null : _reloadStocks,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.iconButtonBackground : AppColors.lightIconButtonBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.iconButtonBorder : AppColors.lightIconButtonBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isReloading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        )
                      else
                        Icon(Icons.refresh, size: 16, color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Reload',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _stocks.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Tap Reload to fetch stock list',
                      style: TextStyle(
                        color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                )
              : CompositedTransformTarget(
                  link: _stockOverlayLink,
                  child: AppTextField(
                    label: '',
                    controller: _stockSearchController,
                    focusNode: _stockFocusNode,
                    hintText: 'Search stock...',
                    suffixIcon: Icon(Icons.arrow_drop_down, size: 24),
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

  Widget _buildDividendSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source Dividend',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_availableDividends.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputBackground : AppColors.lightInputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.inputBorder : AppColors.lightInputBorder,
                  width: 1,
                ),
              ),
              child: Text(
                'No dividend records for ${_selectedTicker ?? "this stock"}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary,
                ),
              ),
            )
          else
            AppDropdownField<int>(
              label: '',
              value: _selectedDividendId,
              items: _availableDividends.map((d) {
                return DropdownMenuItem(
                  value: d.id,
                  child: Text(
                    '${d.exDate.year} - ${FormatUtils.currency(d.netAmount)} (${d.dividendType.name})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDividendId = value;
                  final selected = _availableDividends.firstWhere((d) => d.id == value);
                  _lotsController.text = '${selected.reinvestLots}';
                  _priceController.text = selected.dividendPerLot.toStringAsFixed(0);
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStockDropdown(bool isDark) {
    if (!_showStockDropdown || _filteredStocks.isEmpty) return const SizedBox.shrink();

    return CompositedTransformFollower(
      link: _stockOverlayLink,
      offset: const Offset(0, 52),
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

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppDateField(
        label: 'Date',
        controller: _dateController,
        onDateSelected: (date) => setState(() => _dateController.text = FormatUtils.date(date)),
      ),
    );
  }

  Widget _buildLotsAndPrice(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              label: 'Lots',
              controller: _lotsController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppCurrencyField(
              label: 'Price per Lot',
              controller: _priceController,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppCurrencyField(
        label: 'Fee',
        controller: _feeController,
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildTotalBox(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color.fromRGBO(52, 211, 153, 0.1),
                    Color.fromRGBO(16, 185, 129, 0.05),
                  ]
                : const [
                    Color.fromRGBO(52, 211, 153, 0.15),
                    Color.fromRGBO(16, 185, 129, 0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromRGBO(52, 211, 153, 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Total',
              style: AppTypography.labelSmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              FormatUtils.currency(total),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AppTextField(
        label: 'Notes (optional)',
        controller: _notesController,
        hintText: 'e.g., Reinvest from Q1 dividend',
        maxLines: 2,
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AppButton(
        label: 'Save Transaction',
        onPressed: _save,
      ),
    );
  }
}
