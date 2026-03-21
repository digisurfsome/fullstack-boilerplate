import 'package:apparence_kit/core/data/api/base_api_exceptions.dart';
import 'package:apparence_kit/modules/practitioner/api/entities/session_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionsApiProvider = Provider(
  (ref) => SessionsApi(
    client: Supabase.instance.client,
  ),
);

const _kTable = 'practitioner_sessions';

class SessionsApi {
  final SupabaseClient _client;
  final Logger _logger = Logger();

  SessionsApi({
    required SupabaseClient client,
  }) : _client = client;

  Future<List<SessionEntity>> getAll(String userId) async {
    try {
      final res = await _client
          .from(_kTable)
          .select()
          .eq('user_id', userId)
          .order('started_at', ascending: false);
      if (res.isEmpty) {
        return [];
      }
      return res
          .map((e) => SessionEntity.fromJson(e))
          .toList();
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }

  Future<SessionEntity?> getById(String id) async {
    try {
      final res = await _client
          .from(_kTable)
          .select()
          .eq('id', id);
      if (res.isEmpty) {
        return null;
      }
      return SessionEntity.fromJson(res.first);
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }

  Future<SessionEntity> create(SessionEntity session) async {
    try {
      final data = session.toJson()
        ..remove('id')
        ..remove('creation_date');
      final res = await _client
          .from(_kTable)
          .insert(data)
          .select();
      return SessionEntity.fromJson(res.first);
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }

  Future<void> update(String id, Map<String, dynamic> updates) async {
    try {
      await _client
          .from(_kTable)
          .update(updates)
          .eq('id', id);
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }
}
