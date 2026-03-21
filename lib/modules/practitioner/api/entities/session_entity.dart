// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_entity.freezed.dart';
part 'session_entity.g.dart';

@freezed
sealed class SessionEntity with _$SessionEntity {
  const factory SessionEntity({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'technique_id') required String techniqueId,
    @JsonKey(name: 'target_category') required String targetCategory,
    @JsonKey(name: 'target_description') required String targetDescription,
    @JsonKey(name: 'desired_outcome') required String desiredOutcome,
    @Default('in_progress') String status,
    @JsonKey(name: 'current_phase') @Default('setup') String currentPhase,
    @JsonKey(name: 'initial_intensity') int? initialIntensity,
    @JsonKey(name: 'final_intensity') int? finalIntensity,
    @JsonKey(name: 'intensity_log') @Default([]) List<Map<String, dynamic>> intensityLog,
    @JsonKey(name: 'session_data') @Default({}) Map<String, dynamic> sessionData,
    @JsonKey(name: 'journal_entry') String? journalEntry,
    @JsonKey(name: 'started_at') String? startedAt,
    @JsonKey(name: 'completed_at') String? completedAt,
    @JsonKey(name: 'creation_date') String? creationDate,
  }) = SessionEntityData;

  factory SessionEntity.fromJson(Map<String, dynamic> json) =>
      _$SessionEntityFromJson(json);
}
