import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable labeled input used across the application.
class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled,
    this.focusNode,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
  }) : assert(
          initialValue == null || controller == null,
          'Cannot provide both controller and initialValue',
        );

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool? enabled;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final fillColor = colors.surfaceContainerHighest.withValues(alpha: 0.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primary, width: 1.6),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          readOnly: readOnly,
          enabled: enabled,
          focusNode: focusNode,
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? 1 : minLines,
          inputFormatters: inputFormatters,
        ),
      ],
    );
  }
}
