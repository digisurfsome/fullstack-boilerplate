import 'package:apparence_kit/modules/practitioner/api/entities/session_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'practitioner_session.freezed.dart';

enum TargetCategory { health, financial, relationship, skill, craving, custom }

enum SessionStatus { inProgress, completed, abandoned }

@freezed
sealed class IntensityEntry with _$IntensityEntry {
  const factory IntensityEntry({
    required String phase,
    required int value,
    required DateTime recordedAt,
  }) = IntensityEntryData;
}

@freezed
sealed class PractitionerSession with _$PractitionerSession {
  const factory PractitionerSession({
    required String id,
    required String techniqueId,
    required TargetCategory targetCategory,
    required String targetDescription,
    required String desiredOutcome,
    required SessionStatus status,
    required String currentPhase,
    int? initialIntensity,
    int? finalIntensity,
    @Default([]) List<IntensityEntry> intensityLog,
    @Default({}) Map<String, dynamic> sessionData,
    String? journalEntry,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = PractitionerSessionData;

  const PractitionerSession._();

  bool get isComplete => status == SessionStatus.completed;

  int? get intensityChange {
    if (initialIntensity == null || finalIntensity == null) return null;
    return initialIntensity! - finalIntensity!;
  }

  factory PractitionerSession.fromEntity(SessionEntity entity) {
    final intensityEntries = (entity.intensityLog)
        .map((entry) => IntensityEntry(
              phase: entry['phase'] as String? ?? '',
              value: entry['value'] as int? ?? 0,
              recordedAt: DateTime.tryParse(
                    entry['recorded_at'] as String? ?? '',
                  ) ??
                  DateTime.now(),
            ))
        .toList();

    return PractitionerSession(
      id: entity.id!,
      techniqueId: entity.techniqueId,
      targetCategory: TargetCategory.values.firstWhere(
        (e) => e.name == entity.targetCategory,
        orElse: () => TargetCategory.custom,
      ),
      targetDescription: entity.targetDescription,
      desiredOutcome: entity.desiredOutcome,
      status: _parseStatus(entity.status),
      currentPhase: entity.currentPhase,
      initialIntensity: entity.initialIntensity,
      finalIntensity: entity.finalIntensity,
      intensityLog: intensityEntries,
      sessionData: entity.sessionData,
      journalEntry: entity.journalEntry,
      startedAt: entity.startedAt != null
          ? DateTime.tryParse(entity.startedAt!)
          : null,
      completedAt: entity.completedAt != null
          ? DateTime.tryParse(entity.completedAt!)
          : null,
    );
  }

  static SessionStatus _parseStatus(String status) {
    switch (status) {
      case 'in_progress':
        return SessionStatus.inProgress;
      case 'completed':
        return SessionStatus.completed;
      case 'abandoned':
        return SessionStatus.abandoned;
      default:
        return SessionStatus.inProgress;
    }
  }

  static String statusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.inProgress:
        return 'in_progress';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.abandoned:
        return 'abandoned';
    }
  }
}
