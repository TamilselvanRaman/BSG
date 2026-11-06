import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffix;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  final EdgeInsetsGeometry? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final String? prefixText;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.prefixWidget,
    this.suffix,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.contentPadding,
    this.prefixIconConstraints,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            prefixText: prefixText,
            prefixIconConstraints: prefixIconConstraints ??
                (prefixWidget != null || prefixIcon != null
                    ? const BoxConstraints(minWidth: 36, minHeight: 36)
                    : null),
            prefixIcon: prefixWidget ??
                (prefixIcon != null
                    ? Icon(prefixIcon, size: 18, color: AppColors.textSecondary)
                    : null),
            suffixIcon: suffix,
            contentPadding: contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
          ),
        ),
      ],
    );
  }
}
