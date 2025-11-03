import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Buscar',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool hasValue = controller.text.isNotEmpty;

    return Material(
      color: colors.surfaceContainerHigh,
      elevation: 0,
      borderRadius: BorderRadius.circular(24),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          onChanged?.call(value);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.onSurfaceVariant,
          ),
          suffixIcon: hasValue
              ? IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
