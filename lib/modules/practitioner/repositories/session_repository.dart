import 'package:apparence_kit/modules/practitioner/api/entities/session_entity.dart';
import 'package:apparence_kit/modules/practitioner/api/sessions_api.dart';
import 'package:apparence_kit/modules/practitioner/models/practitioner_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(
    api: ref.read(sessionsApiProvider),
  ),
);

class SessionRepository {
  final SessionsApi _api;

  SessionRepository({
    required SessionsApi api,
  }) : _api = api;

  Future<List<PractitionerSession>> getUserSessions(String userId) async {
    final entities = await _api.getAll(userId);
    return entities
        .map((e) => PractitionerSession.fromEntity(e))
        .toList();
  }

  Future<PractitionerSession> createSession({
    required String userId,
    required String techniqueId,
    required TargetCategory targetCategory,
    required String targetDescription,
    required String desiredOutcome,
  }) async {
    final entity = SessionEntity(
      userId: userId,
      techniqueId: techniqueId,
      targetCategory: targetCategory.name,
      targetDescription: targetDescription,
      desiredOutcome: desiredOutcome,
      startedAt: DateTime.now().toIso8601String(),
    );
    final created = await _api.create(entity);
    return PractitionerSession.fromEntity(created);
  }

  Future<void> updatePhase(String sessionId, String phase) async {
    await _api.update(sessionId, {'current_phase': phase});
  }

  Future<void> recordIntensity(
    String sessionId,
    String phase,
    int value,
    List<Map<String, dynamic>> existingLog,
  ) async {
    final newEntry = {
      'phase': phase,
      'value': value,
      'recorded_at': DateTime.now().toIso8601String(),
    };
    final updatedLog = [...existingLog, newEntry];
    await _api.update(sessionId, {'intensity_log': updatedLog});
  }

  Future<void> completeSession(
    String sessionId, {
    int? finalIntensity,
    String? journalEntry,
  }) async {
    final updates = <String, dynamic>{
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    };
    if (finalIntensity != null) {
      updates['final_intensity'] = finalIntensity;
    }
    if (journalEntry != null) {
      updates['journal_entry'] = journalEntry;
    }
    await _api.update(sessionId, updates);
  }

  Future<void> abandonSession(String sessionId) async {
    await _api.update(sessionId, {
      'status': 'abandoned',
      'completed_at': DateTime.now().toIso8601String(),
    });
  }
}
