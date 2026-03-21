import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:apparence_kit/modules/practitioner/models/submodality_profile.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'practitioner_state.freezed.dart';

@freezed
sealed class PractitionerHomeState with _$PractitionerHomeState {
  const factory PractitionerHomeState({
    @Default([]) List<Technique> techniques,
    SubmodalityProfile? positiveProfile,
    SubmodalityProfile? negativeProfile,
    @Default([]) List<PractitionerSession> recentSessions,
  }) = PractitionerHomeStateData;

  const PractitionerHomeState._();

  bool get hasCompletedProfiling =>
      positiveProfile != null &&
      negativeProfile != null &&
      positiveProfile!.isComplete &&
      negativeProfile!.isComplete;

  double get profilingProgress {
    if (positiveProfile == null && negativeProfile == null) return 0;
    final posProgress = positiveProfile?.completionPercent ?? 0;
    final negProgress = negativeProfile?.completionPercent ?? 0;
    return (posProgress + negProgress) / 2;
  }

  int get completedSessionCount =>
      recentSessions.where((s) => s.isComplete).length;
}

@freezed
sealed class SessionPlayerState with _$SessionPlayerState {
  const factory SessionPlayerState({
    required Technique technique,
    required PractitionerSession session,
    required int currentStepIndex,
    @Default(false) bool isTimerRunning,
    @Default(0) int elapsedSeconds,
    @Default({}) Map<String, dynamic> stepResponses,
  }) = SessionPlayerStateData;

  const SessionPlayerState._();

  ProtocolStep get currentStep => technique.protocol[currentStepIndex];

  bool get isLastStep => currentStepIndex >= technique.protocol.length - 1;

  bool get isFirstStep => currentStepIndex == 0;

  double get progress =>
      (currentStepIndex + 1) / technique.protocol.length;

  String get currentPhaseName => currentStep.phase;
}

@freezed
sealed class ProfileAssessmentState with _$ProfileAssessmentState {
  const factory ProfileAssessmentState({
    required ProfileType profileType,
    required SubmodalityProfile profile,
    @Default(0) int currentQuestionIndex,
  }) = ProfileAssessmentStateData;

  const ProfileAssessmentState._();

  bool get isComplete => currentQuestionIndex >= totalQuestions;

  static const int totalQuestions = 21;

  double get progress => currentQuestionIndex / totalQuestions;
}
