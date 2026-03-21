import 'package:apparence_kit/core/theme/extensions/theme_extension.dart';
import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:flutter/material.dart';

class SessionHistoryCard extends StatelessWidget {
  final PractitionerSession session;

  const SessionHistoryCard({super.key, required this.session});

  IconData get _statusIcon {
    switch (session.status) {
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.inProgress:
        return Icons.play_circle;
      case SessionStatus.abandoned:
        return Icons.cancel;
    }
  }

  Color _statusColor(BuildContext context) {
    switch (session.status) {
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.inProgress:
        return Colors.orange;
      case SessionStatus.abandoned:
        return Colors.red.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: context.colors.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(_statusIcon, color: _statusColor(context), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.targetDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.targetCategory.name,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onBackground.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (session.intensityChange != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: session.intensityChange! > 0
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  session.intensityChange! > 0
                      ? '-${session.intensityChange}'
                      : '${session.intensityChange}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: session.intensityChange! > 0
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
