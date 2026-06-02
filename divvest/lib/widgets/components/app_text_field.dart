import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixText,
    this.onChanged,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.onTap,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: _getTextSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          enabled: enabled,
          validator: validator,
          autovalidateMode: autovalidateMode,
          onTap: onTap,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            prefixStyle: TextStyle(
              color: _getTextSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTextSecondaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
  }
}

class AppCurrencyField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;

  const AppCurrencyField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.onChanged,
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hintText: hintText,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      readOnly: readOnly,
      enabled: enabled,
      prefixText: 'Rp ',
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      focusNode: focusNode,
    );
  }
}

class AppDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onChanged;

  const AppDateField({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? AppColors.backgroundSecondary : Colors.white,
              onSurface: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _formatDate(picked);
      onDateSelected?.call(picked);
      onChanged?.call();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      readOnly: true,
      hintText: 'DD/MM/YYYY',
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        size: 20,
        color: _getTextSecondaryColor(context),
      ),
      onTap: () => _pickDate(context),
    );
  }

  Color _getTextSecondaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final bool enabled;
  final Widget? icon;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.hintText,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: icon,
          ),
          isExpanded: true,
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
          ),
          dropdownColor: isDark ? AppColors.backgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      ],
    );
  }
}
