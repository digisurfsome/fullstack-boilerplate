import 'dart:async';

import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:apparence_kit/modules/practitioner/providers/models/practitioner_state.dart';
import 'package:apparence_kit/modules/practitioner/repositories/session_repository.dart';
import 'package:apparence_kit/modules/practitioner/repositories/technique_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_player_notifier.g.dart';

@riverpod
class SessionPlayerNotifier extends _$SessionPlayerNotifier {
  Timer? _timer;

  @override
  Future<SessionPlayerState> build({
    required String techniqueId,
    required String targetCategory,
    required String targetDescription,
    required String desiredOutcome,
  }) async {
    ref.onDispose(() => _timer?.cancel());
    final techniqueRepo = ref.read(techniqueRepositoryProvider);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final userState = ref.read(userStateNotifierProvider);
    final userId = userState.user.idOrThrow;
    final technique = await techniqueRepo.getById(techniqueId);
    if (technique == null) {
      throw Exception('Technique not found');
    }
    final category = TargetCategory.values.firstWhere(
      (e) => e.name == targetCategory,
      orElse: () => TargetCategory.custom,
    );
    final session = await sessionRepo.createSession(
      userId: userId,
      techniqueId: techniqueId,
      targetCategory: category,
      targetDescription: targetDescription,
      desiredOutcome: desiredOutcome,
    );
    return SessionPlayerState(
      technique: technique,
      session: session,
      currentStepIndex: 0,
    );
  }

  void startTimer() {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    _timer?.cancel();
    state = AsyncData(currentState.copyWith(
      isTimerRunning: true,
      elapsedSeconds: 0,
    ));
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = state.valueOrNull;
      if (s == null) return;
      final newElapsed = s.elapsedSeconds + 1;
      if (newElapsed >= s.currentStep.durationSeconds) {
        _timer?.cancel();
        state = AsyncData(s.copyWith(
          elapsedSeconds: newElapsed,
          isTimerRunning: false,
        ));
      } else {
        state = AsyncData(s.copyWith(elapsedSeconds: newElapsed));
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(isTimerRunning: false));
  }

  Future<void> nextStep() async {
    _timer?.cancel();
    final s = state.valueOrNull;
    if (s == null || s.isLastStep) return;
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final nextIndex = s.currentStepIndex + 1;
    final nextStep = s.technique.protocol[nextIndex];
    await sessionRepo.updatePhase(s.session.id, nextStep.phase);
    state = AsyncData(s.copyWith(
      currentStepIndex: nextIndex,
      isTimerRunning: false,
      elapsedSeconds: 0,
    ));
  }

  Future<void> previousStep() async {
    _timer?.cancel();
    final s = state.valueOrNull;
    if (s == null || s.isFirstStep) return;
    state = AsyncData(s.copyWith(
      currentStepIndex: s.currentStepIndex - 1,
      isTimerRunning: false,
      elapsedSeconds: 0,
    ));
  }

  void recordResponse(String key, dynamic value) {
    final s = state.valueOrNull;
    if (s == null) return;
    final updated = Map<String, dynamic>.from(s.stepResponses);
    updated[key] = value;
    state = AsyncData(s.copyWith(stepResponses: updated));
  }

  Future<void> recordIntensity(int value) async {
    final s = state.valueOrNull;
    if (s == null) return;
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final existingLog = s.session.intensityLog
        .map((e) => {
              'phase': e.phase,
              'value': e.value,
              'recorded_at': e.recordedAt.toIso8601String(),
            })
        .toList();
    await sessionRepo.recordIntensity(
      s.session.id,
      s.currentPhaseName,
      value,
      existingLog,
    );
  }

  Future<void> completeSession({String? journalEntry}) async {
    _timer?.cancel();
    final s = state.valueOrNull;
    if (s == null) return;
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final intensityResponses = s.stepResponses.entries
        .where((e) => e.key.startsWith('intensity_'))
        .toList();
    int? finalIntensity;
    if (intensityResponses.isNotEmpty) {
      finalIntensity = intensityResponses.last.value as int?;
    }
    await sessionRepo.completeSession(
      s.session.id,
      finalIntensity: finalIntensity,
      journalEntry: journalEntry,
    );
    state = AsyncData(s.copyWith(
      session: s.session.copyWith(
        status: SessionStatus.completed,
        completedAt: DateTime.now(),
      ),
    ));
  }

  Future<void> abandonSession() async {
    _timer?.cancel();
    final s = state.valueOrNull;
    if (s == null) return;
    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.abandonSession(s.session.id);
  }
}
