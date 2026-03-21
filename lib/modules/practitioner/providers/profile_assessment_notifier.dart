import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/modules/practitioner/models/submodality_profile.dart';
import 'package:apparence_kit/modules/practitioner/providers/models/practitioner_state.dart';
import 'package:apparence_kit/modules/practitioner/repositories/submodality_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_assessment_notifier.g.dart';

@riverpod
class ProfileAssessmentNotifier extends _$ProfileAssessmentNotifier {
  @override
  ProfileAssessmentState build({required ProfileType profileType}) {
    return ProfileAssessmentState(
      profileType: profileType,
      profile: SubmodalityProfile(profileType: profileType),
    );
  }

  void answerBrightness(ModalityBrightness value) {
    state = state.copyWith(
      profile: state.profile.copyWith(brightness: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerColorType(ColorType value) {
    state = state.copyWith(
      profile: state.profile.copyWith(colorType: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerDistance(Distance value) {
    state = state.copyWith(
      profile: state.profile.copyWith(distance: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerSize(ModalitySize value) {
    state = state.copyWith(
      profile: state.profile.copyWith(size: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerMotion(Motion value) {
    state = state.copyWith(
      profile: state.profile.copyWith(motion: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerFocus(Focus value) {
    state = state.copyWith(
      profile: state.profile.copyWith(focus: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerFraming(Framing value) {
    state = state.copyWith(
      profile: state.profile.copyWith(framing: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerDimensionality(Dimensionality value) {
    state = state.copyWith(
      profile: state.profile.copyWith(dimensionality: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerVolume(Volume value) {
    state = state.copyWith(
      profile: state.profile.copyWith(volume: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerVoiceSource(VoiceSource value) {
    state = state.copyWith(
      profile: state.profile.copyWith(voiceSource: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerSoundDirection(SoundDirection value) {
    state = state.copyWith(
      profile: state.profile.copyWith(soundDirection: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerTempo(Tempo value) {
    state = state.copyWith(
      profile: state.profile.copyWith(tempo: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerPitch(Pitch value) {
    state = state.copyWith(
      profile: state.profile.copyWith(pitch: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerClarity(Clarity value) {
    state = state.copyWith(
      profile: state.profile.copyWith(clarity: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerWeight(Weight value) {
    state = state.copyWith(
      profile: state.profile.copyWith(weight: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerTemperature(Temperature value) {
    state = state.copyWith(
      profile: state.profile.copyWith(temperature: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerBodyLocation(String value) {
    state = state.copyWith(
      profile: state.profile.copyWith(bodyLocation: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerIntensity(int value) {
    state = state.copyWith(
      profile: state.profile.copyWith(intensity: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerPressure(Pressure value) {
    state = state.copyWith(
      profile: state.profile.copyWith(pressure: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerBodyMotion(Motion value) {
    state = state.copyWith(
      profile: state.profile.copyWith(bodyMotion: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void answerPerspective(Perspective value) {
    state = state.copyWith(
      profile: state.profile.copyWith(perspective: value),
      currentQuestionIndex: state.currentQuestionIndex + 1,
    );
  }

  void goBack() {
    if (state.currentQuestionIndex > 0) {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex - 1,
      );
    }
  }

  Future<void> saveProfile() async {
    final userState = ref.read(userStateNotifierProvider);
    final userId = userState.user.idOrThrow;
    final repo = ref.read(submodalityRepositoryProvider);
    await repo.saveProfile(userId, state.profile);
  }
}
