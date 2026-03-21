import 'package:apparence_kit/modules/practitioner/api/entities/submodality_profile_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'submodality_profile.freezed.dart';

enum ProfileType { positive, negative }

enum ModalityBrightness { bright, dark, neutral }

enum ColorType { color, blackAndWhite, muted }

enum Distance { near, far, medium }

enum ModalitySize { large, small, medium }

enum Motion { moving, still }

enum Focus { sharp, fuzzy }

enum Framing { framed, panoramic }

enum Dimensionality { twoD, threeD }

enum Volume { loud, soft, medium }

enum VoiceSource { ownVoice, otherVoice, noVoice }

enum SoundDirection { left, right, surround, behind }

enum Tempo { fast, slow, medium }

enum Pitch { high, low, medium }

enum Clarity { clear, muffled }

enum Weight { heavy, light, neutral }

enum Temperature { warm, cold, neutral }

enum Pressure { pressure, tingle, neutral }

enum Perspective { associated, dissociated }

@freezed
sealed class SubmodalityProfile with _$SubmodalityProfile {
  const factory SubmodalityProfile({
    String? id,
    required ProfileType profileType,
    // Visual
    ModalityBrightness? brightness,
    ColorType? colorType,
    Distance? distance,
    ModalitySize? size,
    Motion? motion,
    Focus? focus,
    Framing? framing,
    Dimensionality? dimensionality,
    // Auditory
    Volume? volume,
    VoiceSource? voiceSource,
    SoundDirection? soundDirection,
    Tempo? tempo,
    Pitch? pitch,
    Clarity? clarity,
    // Kinesthetic
    Weight? weight,
    Temperature? temperature,
    String? bodyLocation,
    int? intensity,
    Pressure? pressure,
    Motion? bodyMotion,
    // Perspective
    Perspective? perspective,
  }) = SubmodalityProfileData;

  const SubmodalityProfile._();

  int get completedCount {
    int count = 0;
    if (brightness != null) count++;
    if (colorType != null) count++;
    if (distance != null) count++;
    if (size != null) count++;
    if (motion != null) count++;
    if (focus != null) count++;
    if (framing != null) count++;
    if (dimensionality != null) count++;
    if (volume != null) count++;
    if (voiceSource != null) count++;
    if (soundDirection != null) count++;
    if (tempo != null) count++;
    if (pitch != null) count++;
    if (clarity != null) count++;
    if (weight != null) count++;
    if (temperature != null) count++;
    if (bodyLocation != null) count++;
    if (intensity != null) count++;
    if (pressure != null) count++;
    if (bodyMotion != null) count++;
    if (perspective != null) count++;
    return count;
  }

  static const int totalModalities = 21;

  double get completionPercent => completedCount / totalModalities;

  bool get isComplete => completedCount == totalModalities;

  factory SubmodalityProfile.fromEntity(SubmodalityProfileEntity entity) {
    return SubmodalityProfile(
      id: entity.id,
      profileType: entity.profileType == 'positive'
          ? ProfileType.positive
          : ProfileType.negative,
      brightness: _parseEnum(ModalityBrightness.values, entity.brightness),
      colorType: _parseColorType(entity.colorType),
      distance: _parseEnum(Distance.values, entity.distance),
      size: _parseEnum(ModalitySize.values, entity.size),
      motion: _parseEnum(Motion.values, entity.motion),
      focus: _parseEnum(Focus.values, entity.focus),
      framing: _parseEnum(Framing.values, entity.framing),
      dimensionality: _parseDimensionality(entity.dimensionality),
      volume: _parseEnum(Volume.values, entity.volume),
      voiceSource: _parseVoiceSource(entity.voiceSource),
      soundDirection: _parseEnum(SoundDirection.values, entity.soundDirection),
      tempo: _parseEnum(Tempo.values, entity.tempo),
      pitch: _parseEnum(Pitch.values, entity.pitch),
      clarity: _parseEnum(Clarity.values, entity.clarity),
      weight: _parseEnum(Weight.values, entity.weight),
      temperature: _parseEnum(Temperature.values, entity.temperature),
      bodyLocation: entity.bodyLocation,
      intensity: entity.intensity,
      pressure: _parseEnum(Pressure.values, entity.pressure),
      bodyMotion: _parseEnum(Motion.values, entity.bodyMotion),
      perspective: _parseEnum(Perspective.values, entity.perspective),
    );
  }

  SubmodalityProfileEntity toEntity(String userId) {
    return SubmodalityProfileEntity(
      id: id,
      userId: userId,
      profileType: profileType == ProfileType.positive ? 'positive' : 'negative',
      brightness: brightness?.name,
      colorType: _colorTypeToString(colorType),
      distance: distance?.name,
      size: size?.name,
      motion: motion?.name,
      focus: focus?.name,
      framing: framing?.name,
      dimensionality: _dimensionalityToString(dimensionality),
      volume: volume?.name,
      voiceSource: _voiceSourceToString(voiceSource),
      soundDirection: soundDirection?.name,
      tempo: tempo?.name,
      pitch: pitch?.name,
      clarity: clarity?.name,
      weight: weight?.name,
      temperature: temperature?.name,
      bodyLocation: bodyLocation,
      intensity: intensity,
      pressure: pressure?.name,
      bodyMotion: bodyMotion?.name,
      perspective: perspective?.name,
    );
  }

  static T? _parseEnum<T extends Enum>(List<T> values, String? value) {
    if (value == null) return null;
    return values.where((e) => e.name == value).firstOrNull;
  }

  static ColorType? _parseColorType(String? value) {
    if (value == null) return null;
    if (value == 'black_and_white') return ColorType.blackAndWhite;
    return _parseEnum(ColorType.values, value);
  }

  static String? _colorTypeToString(ColorType? value) {
    if (value == null) return null;
    if (value == ColorType.blackAndWhite) return 'black_and_white';
    return value.name;
  }

  static Dimensionality? _parseDimensionality(String? value) {
    if (value == null) return null;
    if (value == '2d') return Dimensionality.twoD;
    if (value == '3d') return Dimensionality.threeD;
    return null;
  }

  static String? _dimensionalityToString(Dimensionality? value) {
    if (value == null) return null;
    if (value == Dimensionality.twoD) return '2d';
    if (value == Dimensionality.threeD) return '3d';
    return null;
  }

  static VoiceSource? _parseVoiceSource(String? value) {
    if (value == null) return null;
    if (value == 'own_voice') return VoiceSource.ownVoice;
    if (value == 'other_voice') return VoiceSource.otherVoice;
    if (value == 'no_voice') return VoiceSource.noVoice;
    return null;
  }

  static String? _voiceSourceToString(VoiceSource? value) {
    if (value == null) return null;
    if (value == VoiceSource.ownVoice) return 'own_voice';
    if (value == VoiceSource.otherVoice) return 'other_voice';
    if (value == VoiceSource.noVoice) return 'no_voice';
    return null;
  }
}
