import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

class AppDateField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onChanged;

  AppDateField({
    super.key,
    required this.label,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onChanged,
  });

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  DateTime _tempDate = DateTime.now();

  bool _isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked;

    if (Platform.isIOS) {
      _tempDate = widget.initialDate ?? DateTime.now();
      picked = await showCupertinoModalPopup<DateTime>(
        context: context,
        builder: (context) {
          return Container(
            height: 300,
            color: _isDark(context) ? AppColors.backgroundSecondary : Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _isDark(context) ? AppColors.inputBorder : AppColors.lightInputBorder,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, _tempDate),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    initialDateTime: widget.initialDate ?? DateTime.now(),
                    minimumDate: widget.firstDate ?? DateTime(2000),
                    maximumDate: widget.lastDate ?? DateTime(2100),
                    onDateTimeChanged: (date) => setState(() => _tempDate = date),
                    backgroundColor: _isDark(context) ? AppColors.backgroundSecondary : Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      final theme = Theme.of(context);
      final isDarkMode = theme.brightness == Brightness.dark;

      picked = await showDatePicker(
        context: context,
        initialDate: widget.initialDate ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime(2000),
        lastDate: widget.lastDate ?? DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: isDarkMode
                  ? ColorScheme.dark(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppColors.backgroundSecondary,
                      onSurface: AppColors.textPrimary,
                      onSurfaceVariant: AppColors.textSecondary,
                    )
                  : ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.lightTextPrimary,
                      onSurfaceVariant: AppColors.lightTextSecondary,
                    ),
            ),
            child: child!,
          );
        },
      );
    }

    if (picked != null) {
      widget.controller.text = _formatDate(picked);
      widget.onDateSelected?.call(picked);
      widget.onChanged?.call();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getTextSecondaryColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      readOnly: true,
      hintText: 'DD/MM/YYYY',
      suffixIcon: Icon(
        Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today_outlined,
        size: 20,
        color: _getTextSecondaryColor(context),
      ),
      onTap: () => _pickDate(context),
    );
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
