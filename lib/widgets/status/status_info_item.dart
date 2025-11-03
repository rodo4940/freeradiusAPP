import 'package:flutter/material.dart';

/// Small helper to display a label with its value and an optional leading icon.
class StatusInfoItem extends StatelessWidget {
  const StatusInfoItem({
    super.key,
    required this.label,
    required this.value,
    this.leading,
    this.spacing = 12,
  });

  final String label;
  final String value;
  final Widget? leading;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: spacing),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
