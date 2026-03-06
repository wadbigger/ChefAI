import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe_model.dart';

class HistoryService {
  static const _historyKey = 'recipe_history';
  static const _favoritesKey = 'recipe_favorites';
  static const _maxHistory = 5;

  // ─── HISTORY ──────────────────────────────────────────────────────────────

  Future<List<Recipe>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsons = prefs.getStringList(_historyKey) ?? [];
    return jsons
        .map((j) {
          try {
            return Recipe.fromJson(jsonDecode(j) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();
  }

  Future<void> addToHistory(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];

    // Remove duplicate by name if it exists
    list.removeWhere((j) {
      try {
        return (jsonDecode(j) as Map<String, dynamic>)['name'] == recipe.name;
      } catch (_) {
        return false;
      }
    });

    list.insert(0, jsonEncode(recipe.toJson()));
    if (list.length > _maxHistory) {
      list.removeRange(_maxHistory, list.length);
    }
    await prefs.setStringList(_historyKey, list);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ─── FAVORITES ────────────────────────────────────────────────────────────

  Future<List<Recipe>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsons = prefs.getStringList(_favoritesKey) ?? [];
    return jsons
        .map((j) {
          try {
            return Recipe.fromJson(jsonDecode(j) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();
  }

  Future<bool> isFavorite(String recipeName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsons = prefs.getStringList(_favoritesKey) ?? [];
    return jsons.any((j) {
      try {
        return (jsonDecode(j) as Map<String, dynamic>)['name'] == recipeName;
      } catch (_) {
        return false;
      }
    });
  }

  /// Returns `true` if the recipe is now a favorite, `false` if removed.
  Future<bool> toggleFavorite(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final jsons = prefs.getStringList(_favoritesKey) ?? [];
    final alreadyFav = jsons.any((j) {
      try {
        return (jsonDecode(j) as Map<String, dynamic>)['name'] == recipe.name;
      } catch (_) {
        return false;
      }
    });

    if (alreadyFav) {
      jsons.removeWhere((j) {
        try {
          return (jsonDecode(j) as Map<String, dynamic>)['name'] == recipe.name;
        } catch (_) {
          return false;
        }
      });
    } else {
      jsons.insert(0, jsonEncode(recipe.toJson()));
    }

    await prefs.setStringList(_favoritesKey, jsons);
    return !alreadyFav;
  }
}
