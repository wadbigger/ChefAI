import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/images/generations';
  static const String _model = 'dall-e-3';

  Future<String> generateRecipeImage(
    String recipeName,
    String description,
  ) async {
    final prompt =
        'Professional food photography of $recipeName, $description, '
        'beautifully plated, soft natural lighting, top-down view, '
        'on a rustic wooden table, high resolution, appetizing, restaurant quality';

    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${ApiKeys.openAiApiKey}',
            },
            body: jsonEncode({
              'model': _model,
              'prompt': prompt,
              'n': 1,
              'size': '1024x1024',
              'quality': 'standard',
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw OpenAIException(
              'La génération d\'image a expiré. Réessayez.',
            ),
          );
    } catch (e) {
      if (e is OpenAIException) rethrow;
      throw OpenAIException('Impossible de contacter l\'API OpenAI : $e');
    }

    debugPrint('OpenAI HTTP ${response.statusCode}: ${response.body.substring(0, response.body.length.clamp(0, 300))}');

    switch (response.statusCode) {
      case 200:
        break;
      case 401:
        throw OpenAIException(
          'Clé OpenAI invalide ou sans accès DALL-E (401). Vérifiez la clé et les permissions dans platform.openai.com',
        );
      case 429:
        throw OpenAIException('Quota OpenAI dépassé ou crédits insuffisants (429). Ajoutez des crédits sur platform.openai.com/billing');
      case 400:
        throw OpenAIException(
          'Requête DALL-E invalide (400) : ${response.body}',
        );
      default:
        throw OpenAIException(
          'Erreur API OpenAI (HTTP ${response.statusCode}) : ${response.body}',
        );
    }

    late Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw OpenAIException('La réponse OpenAI n\'est pas un JSON valide.');
    }

    final imageList = data['data'] as List?;
    if (imageList == null || imageList.isEmpty) {
      throw OpenAIException('Aucune image générée par DALL-E.');
    }

    final url = (imageList.first as Map<String, dynamic>)['url'] as String?;
    if (url == null || url.isEmpty) {
      throw OpenAIException('URL d\'image manquante dans la réponse DALL-E.');
    }

    return url;
  }
}

class OpenAIException implements Exception {
  final String message;
  const OpenAIException(this.message);

  @override
  String toString() => message;
}
