import 'package:apparence_kit/core/states/user_state_notifier.dart';
import 'package:apparence_kit/modules/practitioner/providers/models/practitioner_state.dart';
import 'package:apparence_kit/modules/practitioner/repositories/session_repository.dart';
import 'package:apparence_kit/modules/practitioner/repositories/submodality_repository.dart';
import 'package:apparence_kit/modules/practitioner/repositories/technique_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'practitioner_home_notifier.g.dart';

@Riverpod(keepAlive: false)
class PractitionerHomeNotifier extends _$PractitionerHomeNotifier {
  @override
  Future<PractitionerHomeState> build() async {
    final userState = ref.read(userStateNotifierProvider);
    final userId = userState.user.idOrThrow;
    final submodalityRepo = ref.read(submodalityRepositoryProvider);
    final techniqueRepo = ref.read(techniqueRepositoryProvider);
    final sessionRepo = ref.read(sessionRepositoryProvider);
    final (techniques, positiveProfile, negativeProfile, recentSessions) =
        await (
      techniqueRepo.getAll(),
      submodalityRepo.getPositiveProfile(userId),
      submodalityRepo.getNegativeProfile(userId),
      sessionRepo.getUserSessions(userId),
    ).wait;
    return PractitionerHomeState(
      techniques: techniques,
      positiveProfile: positiveProfile,
      negativeProfile: negativeProfile,
      recentSessions: recentSessions,
    );
  }
}
