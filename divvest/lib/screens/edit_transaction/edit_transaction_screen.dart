import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../data/models/models.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/components/components.dart';

class EditTransactionScreen extends StatefulWidget {
  final PortfolioEntry entry;

  const EditTransactionScreen({super.key, required this.entry});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late bool isBuy;
  late TextEditingController _stockController;
  late TextEditingController _dateController;
  late TextEditingController _lotsController;
  late TextEditingController _priceController;
  late TextEditingController _feeController;
  late TextEditingController _notesController;

  bool _isLoading = false;

  double get total {
    final lots = int.tryParse(_lotsController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final fee = double.tryParse(_feeController.text) ?? 0;
    return (lots * 100 * price) + fee;
  }

  @override
  void initState() {
    super.initState();
    isBuy = true;
    _stockController = TextEditingController(text: widget.entry.ticker);
    _dateController =
        TextEditingController(text: FormatUtils.date(widget.entry.buyDate));
    _lotsController = TextEditingController(text: widget.entry.lots.toString());
    _priceController = TextEditingController(
        text: widget.entry.pricePerLot.toStringAsFixed(0));
    _feeController =
        TextEditingController(text: widget.entry.fee.toStringAsFixed(0));
    _notesController = TextEditingController(text: widget.entry.notes);
  }

  @override
  void dispose() {
    _stockController.dispose();
    _dateController.dispose();
    _lotsController.dispose();
    _priceController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final lots = int.tryParse(_lotsController.text);
    final price = double.tryParse(_priceController.text);
    final fee = double.tryParse(_feeController.text) ?? 0;

    if (lots == null || price == null || lots <= 0 || price <= 0) {
      AppSnackBar.showError(context, 'Please fill in valid Lots and Price');
      return;
    }

    setState(() => _isLoading = true);

    final updatedEntry = PortfolioEntry(
      id: widget.entry.id,
      ticker: widget.entry.ticker,
      buyDate: widget.entry.buyDate,
      lots: lots,
      pricePerLot: price,
      fee: fee,
      isReinvested: widget.entry.isReinvested,
      sourceDividendId: widget.entry.sourceDividendId,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await context.read<PortfolioProvider>().updateEntry(updatedEntry);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, 'Transaction updated successfully');
    }
  }

  Future<void> _delete() async {
    final confirmed = await AppDialog.showDeleteConfirmation(
      context: context,
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this ${widget.entry.ticker} transaction?',
    );

    if (confirmed == true && mounted) {
      await context.read<PortfolioProvider>().deleteEntry(widget.entry.id);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        AppSnackBar.showSuccess(context, 'Transaction deleted');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppScaffold(
      title: 'Edit Transaction',
      actions: [
        AppIconButton(
          icon: Platform.isIOS ? CupertinoIcons.trash : Icons.delete_outline,
          onPressed: _delete,
          backgroundColor: const Color.fromRGBO(239, 68, 68, 0.1),
          borderColor: const Color.fromRGBO(239, 68, 68, 0.3),
          iconColor: AppColors.error,
        ),
      ],
      body: AppLoadingOverlay(
        isLoading: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildToggle(isDark),
                _buildStockField(),
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
        ),
      ),
    );
  }

  Widget _buildToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Center(
          child: Text(
            isBuy ? '📥 Buy' : '📤 Sell',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppTextField(
        label: 'Stock',
        controller: _stockController,
        readOnly: true,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: AppTextField(
        label: 'Date',
        controller: _dateController,
        readOnly: true,
        suffixIcon: Icon(
            Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today,
            size: 18),
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
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
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
        label: 'Update Transaction',
        onPressed: _save,
      ),
    );
  }
}
