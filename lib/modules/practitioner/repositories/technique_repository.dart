import 'package:apparence_kit/modules/practitioner/api/techniques_api.dart';
import 'package:apparence_kit/modules/practitioner/models/technique.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final techniqueRepositoryProvider = Provider<TechniqueRepository>(
  (ref) => TechniqueRepository(
    api: ref.read(techniquesApiProvider),
  ),
);

class TechniqueRepository {
  final TechniquesApi _api;

  TechniqueRepository({
    required TechniquesApi api,
  }) : _api = api;

  Future<List<Technique>> getAll() async {
    final entities = await _api.getAll();
    return entities.map((e) => Technique.fromEntity(e)).toList();
  }

  Future<Technique?> getById(String id) async {
    final entity = await _api.getById(id);
    if (entity == null) return null;
    return Technique.fromEntity(entity);
  }

  Future<List<Technique>> getByCategory(TechniqueCategory category) async {
    final entities = await _api.getByCategory(category.name);
    return entities.map((e) => Technique.fromEntity(e)).toList();
  }
}
