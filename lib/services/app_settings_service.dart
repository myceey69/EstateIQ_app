import 'package:supabase_flutter/supabase_flutter.dart';

class AppSettingsService {
  AppSettingsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Map<String, String> _cache = {};

  Future<String> getSetting(String key) async {
    final cached = _cache[key];
    if (cached != null) return cached;

    final response = await _client
        .from('app_settings')
        .select('value')
        .eq('key', key)
        .maybeSingle();

    final value = response?['value']?.toString() ?? '';
    if (value.isNotEmpty) _cache[key] = value;
    return value;
  }
}
