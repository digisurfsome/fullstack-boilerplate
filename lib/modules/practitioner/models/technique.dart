import 'package:apparence_kit/modules/practitioner/api/entities/technique_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'technique.freezed.dart';

enum TechniqueCategory { nlp, eft, hypnosis, visualization, hybrid }

enum TechniqueDifficulty { beginner, intermediate, advanced }

@freezed
sealed class ProtocolStep with _$ProtocolStep {
  const factory ProtocolStep({
    required String phase,
    required String title,
    required String instruction,
    required int durationSeconds,
    required String type,
    int? repetitions,
    int? minimum,
    List<String>? options,
    String? point,
  }) = ProtocolStepData;

  factory ProtocolStep.fromJson(Map<String, dynamic> json) {
    return ProtocolStep(
      phase: json['phase'] as String,
      title: json['title'] as String,
      instruction: json['instruction'] as String,
      durationSeconds: json['duration_seconds'] as int,
      type: json['type'] as String,
      repetitions: json['repetitions'] as int?,
      minimum: json['minimum'] as int?,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      point: json['point'] as String?,
    );
  }
}

@freezed
sealed class Technique with _$Technique {
  const factory Technique({
    required String id,
    required String name,
    required String description,
    required TechniqueCategory category,
    required TechniqueDifficulty difficulty,
    required int durationMinutes,
    required List<ProtocolStep> protocol,
    required bool targetsVisual,
    required bool targetsAuditory,
    required bool targetsKinesthetic,
    required bool targetsPerspective,
  }) = TechniqueData;

  const Technique._();

  String get categoryLabel {
    switch (category) {
      case TechniqueCategory.nlp:
        return 'NLP';
      case TechniqueCategory.eft:
        return 'EFT';
      case TechniqueCategory.hypnosis:
        return 'Hypnosis';
      case TechniqueCategory.visualization:
        return 'Visualization';
      case TechniqueCategory.hybrid:
        return 'Hybrid';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case TechniqueDifficulty.beginner:
        return 'Beginner';
      case TechniqueDifficulty.intermediate:
        return 'Intermediate';
      case TechniqueDifficulty.advanced:
        return 'Advanced';
    }
  }

  factory Technique.fromEntity(TechniqueEntity entity) {
    final id = entity.id;
    if (id == null) {
      throw StateError('TechniqueEntity.id must not be null when converting to model');
    }
    return Technique(
      id: id,
      name: entity.name,
      description: entity.description,
      category: TechniqueCategory.values.firstWhere(
        (e) => e.name == entity.category,
        orElse: () => TechniqueCategory.nlp,
      ),
      difficulty: TechniqueDifficulty.values.firstWhere(
        (e) => e.name == entity.difficulty,
        orElse: () => TechniqueDifficulty.beginner,
      ),
      durationMinutes: entity.durationMinutes,
      protocol: entity.protocol
          .map((step) => ProtocolStep.fromJson(step))
          .toList(),
      targetsVisual: entity.targetsVisual,
      targetsAuditory: entity.targetsAuditory,
      targetsKinesthetic: entity.targetsKinesthetic,
      targetsPerspective: entity.targetsPerspective,
    );
  }
}
