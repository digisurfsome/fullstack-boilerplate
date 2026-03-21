// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_target_entity.freezed.dart';
part 'swap_target_entity.g.dart';

@freezed
sealed class SwapTargetEntity with _$SwapTargetEntity {
  const factory SwapTargetEntity({
    String? id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'source_label') required String sourceLabel,
    @JsonKey(name: 'source_modalities') @Default({}) Map<String, dynamic> sourceModalities,
    @JsonKey(name: 'destination_label') required String destinationLabel,
    @JsonKey(name: 'destination_modalities') @Default({}) Map<String, dynamic> destinationModalities,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'swap_type') required String swapType,
    String? notes,
    @JsonKey(name: 'creation_date') String? creationDate,
    @JsonKey(name: 'last_update_date') String? lastUpdateDate,
  }) = SwapTargetEntityData;

  factory SwapTargetEntity.fromJson(Map<String, dynamic> json) =>
      _$SwapTargetEntityFromJson(json);
}
