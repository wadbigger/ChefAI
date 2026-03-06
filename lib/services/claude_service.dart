import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';
import '../models/recipe_model.dart';

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-opus-4-5';
  static const String _anthropicVersion = '2023-06-01';

  Future<Recipe> generateRecipe({
    required List<String> ingredients,
    required String cuisine,
    required String diet,
    required int maxTime,
  }) async {
    final prompt = _buildPrompt(
      ingredients: ingredients,
      cuisine: cuisine,
      diet: diet,
      maxTime: maxTime,
    );

    late http.Response response;

    try {
      response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'content-type': 'application/json',
              'x-api-key': ApiKeys.claudeApiKey,
              'anthropic-version': _anthropicVersion,
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 1500,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw ClaudeException(
              'La requête a expiré. Vérifiez votre connexion internet.',
            ),
          );
    } catch (e) {
      if (e is ClaudeException) rethrow;
      throw ClaudeException('Impossible de contacter l\'API Claude : $e');
    }

    _checkHttpStatus(response);

    return _parseResponse(response.body);
  }

  void _checkHttpStatus(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return;
      case 401:
        throw ClaudeException(
          'Clé API invalide. Vérifiez ApiKeys.claudeApiKey dans lib/config/api_keys.dart',
        );
      case 429:
        throw ClaudeException(
          'Quota API dépassé. Réessayez dans quelques instants.',
        );
      case 500:
      case 529:
        throw ClaudeException(
          'L\'API Anthropic est temporairement indisponible (${response.statusCode}).',
        );
      default:
        throw ClaudeException(
          'Erreur API inattendue (HTTP ${response.statusCode}) : ${response.body}',
        );
    }
  }

  Recipe _parseResponse(String responseBody) {
    late Map<String, dynamic> data;
    try {
      data = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      throw ClaudeException('La réponse de Claude n\'est pas un JSON valide.');
    }

    final content = data['content'] as List?;
    if (content == null || content.isEmpty) {
      throw ClaudeException('Claude a retourné une réponse vide.');
    }

    final rawText = content.first['text'] as String? ?? '';

    // Extract the JSON block from the text (Claude may add surrounding prose)
    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
    if (jsonMatch == null) {
      throw ClaudeException(
        'Impossible de trouver un objet JSON dans la réponse de Claude.\n'
        'Réponse reçue : $rawText',
      );
    }

    late Map<String, dynamic> recipeJson;
    try {
      recipeJson = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
    } catch (_) {
      throw ClaudeException(
        'Le JSON extrait de la réponse de Claude est malformé.',
      );
    }

    try {
      return Recipe.fromJson(recipeJson);
    } catch (e) {
      throw ClaudeException(
        'Les données de la recette sont incomplètes ou invalides : $e',
      );
    }
  }

  String _buildPrompt({
    required List<String> ingredients,
    required String cuisine,
    required String diet,
    required int maxTime,
  }) {
    return '''Tu es un chef cuisinier expert. Génère une recette créative et détaillée.

Contraintes :
- Ingrédients disponibles : ${ingredients.join(', ')}
- Type de cuisine : $cuisine
- Régime alimentaire : $diet
- Temps de préparation total maximum : $maxTime minutes

IMPORTANT : Réponds UNIQUEMENT avec un objet JSON valide, sans texte avant ni après. Respecte exactement ce format :
{
  "name": "Nom de la recette",
  "description": "Description courte et appétissante (2-3 phrases)",
  "ingredients": [
    "200g de ...",
    "2 cuillères à soupe de ..."
  ],
  "steps": [
    "Commencer par ...",
    "Ensuite ..."
  ],
  "prepTime": 30,
  "servings": 4,
  "difficulty": "Facile",
  "imageUrl": ""
}

Règles :
- "prepTime" est un entier (minutes totales, préparation + cuisson)
- "servings" est un entier (nombre de personnes)
- "difficulty" est l'une des valeurs : "Facile", "Moyen", "Difficile"
- "imageUrl" laisse la valeur vide ""
- Les "steps" ne doivent pas inclure le numéro d'étape, juste le texte''';
  }
}

class ClaudeException implements Exception {
  final String message;
  const ClaudeException(this.message);

  @override
  String toString() => message;
}
