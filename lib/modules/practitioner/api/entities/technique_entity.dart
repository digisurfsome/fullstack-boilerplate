// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'technique_entity.freezed.dart';
part 'technique_entity.g.dart';

@freezed
sealed class TechniqueEntity with _$TechniqueEntity {
  const factory TechniqueEntity({
    String? id,
    required String name,
    required String description,
    required String category,
    required String difficulty,
    @JsonKey(name: 'duration_minutes') required int durationMinutes,
    required List<Map<String, dynamic>> protocol,
    @JsonKey(name: 'targets_visual') @Default(false) bool targetsVisual,
    @JsonKey(name: 'targets_auditory') @Default(false) bool targetsAuditory,
    @JsonKey(name: 'targets_kinesthetic') @Default(false) bool targetsKinesthetic,
    @JsonKey(name: 'targets_perspective') @Default(false) bool targetsPerspective,
    @Default(true) bool active,
    @JsonKey(name: 'creation_date') String? creationDate,
  }) = TechniqueEntityData;

  factory TechniqueEntity.fromJson(Map<String, dynamic> json) =>
      _$TechniqueEntityFromJson(json);
}
