import 'package:apparence_kit/core/data/api/base_api_exceptions.dart';
import 'package:apparence_kit/modules/practitioner/api/entities/technique_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final techniquesApiProvider = Provider(
  (ref) => TechniquesApi(
    client: Supabase.instance.client,
  ),
);

const _kTable = 'techniques';

class TechniquesApi {
  final SupabaseClient _client;
  final Logger _logger = Logger();

  TechniquesApi({
    required SupabaseClient client,
  }) : _client = client;

  Future<List<TechniqueEntity>> getAll() async {
    try {
      final res = await _client
          .from(_kTable)
          .select()
          .eq('active', true);
      if (res.isEmpty) {
        return [];
      }
      return res
          .map((e) => TechniqueEntity.fromJson(e))
          .toList();
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }

  Future<TechniqueEntity?> getById(String id) async {
    try {
      final res = await _client
          .from(_kTable)
          .select()
          .eq('id', id);
      if (res.isEmpty) {
        return null;
      }
      return TechniqueEntity.fromJson(res.first);
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }

  Future<List<TechniqueEntity>> getByCategory(String category) async {
    try {
      final res = await _client
          .from(_kTable)
          .select()
          .eq('active', true)
          .eq('category', category);
      if (res.isEmpty) {
        return [];
      }
      return res
          .map((e) => TechniqueEntity.fromJson(e))
          .toList();
    } catch (e) {
      _logger.e(e);
      throw ApiError(code: 0, message: '$e');
    }
  }
}
