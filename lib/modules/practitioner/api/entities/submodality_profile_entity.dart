// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'submodality_profile_entity.freezed.dart';
part 'submodality_profile_entity.g.dart';

@freezed
sealed class SubmodalityProfileEntity with _$SubmodalityProfileEntity {
  const factory SubmodalityProfileEntity({
    @JsonKey(includeIfNull: false) String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'profile_type') required String profileType,
    // Visual
    String? brightness,
    @JsonKey(name: 'color_type') String? colorType,
    String? distance,
    String? size,
    String? motion,
    String? focus,
    String? framing,
    String? dimensionality,
    // Auditory
    String? volume,
    @JsonKey(name: 'voice_source') String? voiceSource,
    @JsonKey(name: 'sound_direction') String? soundDirection,
    String? tempo,
    String? pitch,
    String? clarity,
    // Kinesthetic
    String? weight,
    String? temperature,
    @JsonKey(name: 'body_location') String? bodyLocation,
    int? intensity,
    String? pressure,
    @JsonKey(name: 'body_motion') String? bodyMotion,
    // Perspective
    String? perspective,
    // Metadata
    @JsonKey(name: 'creation_date') String? creationDate,
    @JsonKey(name: 'last_update_date') String? lastUpdateDate,
  }) = SubmodalityProfileEntityData;

  factory SubmodalityProfileEntity.fromJson(Map<String, dynamic> json) =>
      _$SubmodalityProfileEntityFromJson(json);
}
