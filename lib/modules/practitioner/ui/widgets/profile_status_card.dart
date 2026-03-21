import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileStatusCard extends StatelessWidget {
  final bool hasCompletedProfiling;
  final double profilingProgress;
  final VoidCallback onStartProfiling;

  const ProfileStatusCard({
    super.key,
    required this.hasCompletedProfiling,
    required this.profilingProgress,
    required this.onStartProfiling,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        onStartProfiling();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasCompletedProfiling
                ? [
                    context.colors.primary.withValues(alpha: 0.15),
                    context.colors.primary.withValues(alpha: 0.05),
                  ]
                : [
                    context.colors.primary,
                    context.colors.primary.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasCompletedProfiling ? Icons.check_circle : Icons.psychology,
                  color: hasCompletedProfiling
                      ? context.colors.primary
                      : context.colors.onPrimary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasCompletedProfiling
                        ? 'Neural Profile Complete'
                        : 'Set Up Your Neural Profile',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: hasCompletedProfiling
                          ? context.colors.onBackground
                          : context.colors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!hasCompletedProfiling)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: context.colors.onPrimary.withValues(alpha: 0.7),
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasCompletedProfiling
                  ? 'Your positive and negative modality signatures are mapped. Tap to update.'
                  : 'Map how your brain codes positive and negative experiences to unlock personalized sessions.',
              style: context.textTheme.bodySmall?.copyWith(
                color: hasCompletedProfiling
                    ? context.colors.onBackground.withValues(alpha: 0.6)
                    : context.colors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            if (!hasCompletedProfiling && profilingProgress > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: profilingProgress,
                  backgroundColor:
                      context.colors.onPrimary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.onPrimary,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(profilingProgress * 100).round()}% complete',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onPrimary.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
