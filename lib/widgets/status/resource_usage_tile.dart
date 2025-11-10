import 'package:flutter/material.dart';

class ResourceUsageTile extends StatelessWidget {
  const ResourceUsageTile({
    super.key,
    required this.label,
    required this.percent,
    this.height = 8,
  }) : assert(percent >= 0 && percent <= 100);

  final String label;
  final double percent;
  final double height;

  Color _resolveColor(ColorScheme colors) {
    if (percent >= 80) {
      return colors.error;
    }
    if (percent >= 50) {
      return colors.tertiary;
    }
    return colors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final barColor = _resolveColor(colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: height,
            color: barColor,
            backgroundColor: colors.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
