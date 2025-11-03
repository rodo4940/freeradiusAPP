import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.gradient,
    this.icon = HeroIcons.user,
  });

  final String name;
  final String subtitle;
  final Gradient? gradient;
  final HeroIcons icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final decoration =
        gradient ??
        LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.85),
            colors.tertiary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: decoration,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HeroIcon(icon, size: 32, color: colors.onPrimary),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
