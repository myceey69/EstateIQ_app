import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/property.dart';
import 'app_settings_service.dart';

class GeminiService {
  GeminiService({
    http.Client? client,
    String? apiKey,
    String? model,
    AppSettingsService? settings,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY'),
        _settings = settings ?? AppSettingsService(),
        _model = model ??
            const String.fromEnvironment(
              'GEMINI_MODEL',
              defaultValue: 'gemini-3-flash-preview',
            );

  final http.Client _client;
  final String _apiKey;
  final AppSettingsService _settings;
  final String _model;

  bool get isConfigured => true;

  Future<String> ask({
    required String question,
    required List<Property> properties,
  }) async {
    final apiKey = _apiKey.isNotEmpty
        ? _apiKey
        : await _settings.getSetting('gemini_api_key');

    if (apiKey.isEmpty) {
      throw const GeminiConfigurationException(
        'Gemini API key is missing in Supabase app_settings.',
      );
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
    );

    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': _buildPrompt(question, properties)},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.4,
          'maxOutputTokens': 700,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiRequestException(
        'Gemini request failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>? ?? [];
    final content = candidates.isEmpty
        ? null
        : candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>? ?? [];
    final text = parts
        .map((part) => part is Map<String, dynamic> ? part['text'] : null)
        .whereType<String>()
        .join('\n')
        .trim();

    if (text.isEmpty) {
      throw const GeminiRequestException('Gemini returned an empty response.');
    }
    return text;
  }

  String _buildPrompt(String question, List<Property> properties) {
    final inventory = properties.take(12).map((p) {
      return '- ${p.title}: ${p.priceFormatted}, ${p.beds} bd/${p.baths} ba, '
          '${p.sqft} sqft, risk ${p.risk}, growth ${p.growth}, cap rate ${p.capRate}, '
          'signal ${p.signal}, address ${p.address}.';
    }).join('\n');

    return '''
You are EstateIQ's real estate analysis assistant.
Answer only questions related to this app, real estate investing, property listings, ROI, valuation, market trends, neighborhood quality, and saved properties.
Use the app inventory below when it helps. If the user asks for legal, tax, loan, or investment advice, provide educational guidance and suggest confirming with a qualified professional.
Keep answers concise, practical, and friendly.

Current EstateIQ inventory:
$inventory

User question:
$question
''';
  }
}

class GeminiConfigurationException implements Exception {
  const GeminiConfigurationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class GeminiRequestException implements Exception {
  const GeminiRequestException(this.message);
  final String message;

  @override
  String toString() => message;
}
