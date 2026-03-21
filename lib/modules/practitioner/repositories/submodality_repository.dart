import 'package:apparence_kit/modules/practitioner/api/submodality_profiles_api.dart';
import 'package:apparence_kit/modules/practitioner/models/submodality_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submodalityRepositoryProvider = Provider<SubmodalityRepository>(
  (ref) => SubmodalityRepository(
    api: ref.read(submodalityProfilesApiProvider),
  ),
);

class SubmodalityRepository {
  final SubmodalityProfilesApi _api;

  SubmodalityRepository({
    required SubmodalityProfilesApi api,
  }) : _api = api;

  Future<List<SubmodalityProfile>> getProfiles(String userId) async {
    final entities = await _api.getAll(userId);
    return entities
        .map((e) => SubmodalityProfile.fromEntity(e))
        .toList();
  }

  Future<SubmodalityProfile?> getPositiveProfile(String userId) async {
    final entity = await _api.getByType(userId, 'positive');
    if (entity == null) return null;
    return SubmodalityProfile.fromEntity(entity);
  }

  Future<SubmodalityProfile?> getNegativeProfile(String userId) async {
    final entity = await _api.getByType(userId, 'negative');
    if (entity == null) return null;
    return SubmodalityProfile.fromEntity(entity);
  }

  Future<void> saveProfile(
    String userId,
    SubmodalityProfile profile,
  ) async {
    final entity = profile.toEntity(userId);
    await _api.upsert(entity);
  }
}
