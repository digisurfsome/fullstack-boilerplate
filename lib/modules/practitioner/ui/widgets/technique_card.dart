import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TechniqueCard extends StatelessWidget {
  final Technique technique;
  final VoidCallback onTap;

  const TechniqueCard({
    super.key,
    required this.technique,
    required this.onTap,
  });

  IconData get _categoryIcon {
    switch (technique.category) {
      case TechniqueCategory.nlp:
        return Icons.swap_horiz;
      case TechniqueCategory.eft:
        return Icons.touch_app;
      case TechniqueCategory.hypnosis:
        return Icons.self_improvement;
      case TechniqueCategory.visualization:
        return Icons.visibility;
      case TechniqueCategory.hybrid:
        return Icons.merge_type;
    }
  }

  Color _categoryColor(BuildContext context) {
    switch (technique.category) {
      case TechniqueCategory.nlp:
        return Colors.blue;
      case TechniqueCategory.eft:
        return Colors.green;
      case TechniqueCategory.hypnosis:
        return Colors.purple;
      case TechniqueCategory.visualization:
        return Colors.orange;
      case TechniqueCategory.hybrid:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(context);
    return InkWell(
      onTap: () {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.mediumImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: context.colors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon, color: catColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technique.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      technique.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onBackground.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Tag(
                          label: technique.categoryLabel,
                          color: catColor,
                        ),
                        const SizedBox(width: 8),
                        _Tag(
                          label: technique.difficultyLabel,
                          color: context.colors.onBackground.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: context.colors.onBackground.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${technique.durationMinutes} min',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.onBackground
                                .withValues(alpha: 0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colors.onBackground.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: context.textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
