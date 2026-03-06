# ChefAI 🍽️

**Votre chef personnel IA** — Générez des recettes sur mesure à partir de vos ingrédients, avec une photo du plat générée par DALL-E 3.

---

## Fonctionnalités

- 🤖 **Génération de recettes** via Claude (Anthropic)
- 🎨 **Photo du plat** générée par DALL-E 3 (OpenAI)
- 📋 **Historique** des 5 dernières recettes
- ❤️ **Favoris** sauvegardés localement
- 📤 **Partage** de recettes via share sheet natif
- 📡 **Détection hors-ligne** avec message d'erreur clair
- 🌙 Thème sombre élégant avec orange #FF6B35

---

## Installation

### Prérequis

- Flutter SDK ≥ 3.11.0
- Dart SDK ≥ 3.11.0
- Android SDK (API 21+) ou Xcode 14+ pour iOS

### 1. Cloner le projet

```bash
git clone <url-du-repo>
cd ChefAI
```

### 2. Configurer les clés API

Créez le fichier `lib/config/api_keys.dart` (ce fichier est dans `.gitignore`) :

```dart
class ApiKeys {
  /// Clé API Anthropic (Claude) — https://console.anthropic.com/
  static const String claudeApiKey = 'sk-ant-...';

  /// Clé API OpenAI (DALL-E 3) — https://platform.openai.com/api-keys
  static const String openAiApiKey = 'sk-proj-...';
}
```

> ⚠️ **Ne commitez jamais ce fichier.** Il est automatiquement ignoré par `.gitignore`.

### Obtenir les clés API

| Service | Lien | Notes |
|---------|------|-------|
| Claude (Anthropic) | [console.anthropic.com](https://console.anthropic.com/) | Modèle : `claude-opus-4-5` |
| OpenAI (DALL-E 3) | [platform.openai.com](https://platform.openai.com/api-keys) | Nécessite des crédits pour DALL-E |

### 3. Installer les dépendances

```bash
flutter pub get
```

### 4. Lancer l'application

```bash
# Sur Android (appareil connecté)
flutter run -d <device-id>

# Sur Chrome (développement web)
flutter run -d chrome --web-browser-flag="--disable-web-security"

# Lister les appareils disponibles
flutter devices
```

---

## Structure du projet

```
lib/
├── config/
│   └── api_keys.dart          # ⚠️ Non versionné — à créer manuellement
├── models/
│   └── recipe_model.dart      # Modèle Recipe avec copyWith
├── screens/
│   ├── home_screen.dart       # Formulaire principal
│   ├── recipe_screen.dart     # Affichage de la recette
│   └── history_screen.dart    # Historique + Favoris
├── services/
│   ├── claude_service.dart    # API Anthropic
│   ├── openai_service.dart    # API OpenAI (DALL-E 3)
│   └── history_service.dart   # SharedPreferences (historique/favoris)
└── widgets/
    ├── error_dialog.dart      # Dialog d'erreur réutilisable
    ├── ingredient_chip.dart   # Chips d'ingrédients
    ├── input_form.dart        # Composants de formulaire
    └── loading_overlay.dart   # Overlay de chargement avec Lottie
assets/
└── cooking_animation.json    # Animation Lottie de chargement
```

---

## Packages utilisés

| Package | Version | Usage |
|---------|---------|-------|
| `google_fonts` | ^6.2.1 | Playfair Display + Lato |
| `http` | ^1.2.1 | Appels API REST |
| `cached_network_image` | ^3.4.1 | Images DALL-E avec cache |
| `share_plus` | ^10.1.4 | Partage natif |
| `lottie` | ^3.1.2 | Animation de chargement |
| `shared_preferences` | ^2.3.2 | Historique + Favoris |
| `connectivity_plus` | ^6.1.2 | Détection hors-ligne |
| `flutter_animate` | ^4.5.0 | Animations d'entrée |
| `gap` | ^3.0.1 | Espacement |

---

## Dépannage

### "Impossible de générer la recette"
- Vérifiez votre clé Claude dans `api_keys.dart`
- Vérifiez votre connexion internet
- Consultez [status.anthropic.com](https://status.anthropic.com)

### "Image non disponible"
- Vérifiez votre clé OpenAI dans `api_keys.dart`
- Assurez-vous d'avoir des crédits sur [platform.openai.com/billing](https://platform.openai.com/billing)
- DALL-E 3 nécessite un accès spécifique — vérifiez les permissions de votre clé

### Build Gradle échoue
```bash
flutter clean
flutter pub get
flutter run
```
