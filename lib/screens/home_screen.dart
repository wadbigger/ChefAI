import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../services/claude_service.dart';
import '../services/history_service.dart';
import '../services/openai_service.dart';
import '../widgets/error_dialog.dart';
import '../widgets/ingredient_chip.dart';
import '../widgets/input_form.dart';
import '../widgets/loading_overlay.dart';
import 'history_screen.dart';
import 'recipe_screen.dart';

const _skyBlue = Color(0xFF29B6F6);
const _lightBg = Color(0xFFF0F7FF);
const _white = Color(0xFFFFFFFF);
const _border = Color(0xFFCCE5F5);
const _textPrimary = Color(0xFF1A2E42);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _ingredients = [];
  String _cuisineType = 'Française';
  String _dietType = 'Normal';
  double _prepTime = 30;
  bool _isLoading = false;
  String _loadingLabel = '';

  final _historyService = HistoryService();

  static const List<String> _cuisineTypes = [
    'Française', 'Italienne', 'Asiatique', 'Mexicaine',
    'Méditerranéenne', 'Indienne', 'Japonaise', 'Américaine',
  ];

  static const List<String> _dietTypes = [
    'Normal', 'Végétarien', 'Vegan', 'Sans gluten', 'Faible en calories',
  ];

  // ─── CONNECTIVITY ─────────────────────────────────────────────────────────

  Future<bool> _isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  // ─── GENERATE RECIPE ──────────────────────────────────────────────────────

  Future<void> _generateRecipe() async {
    if (_ingredients.isEmpty) {
      _showSnackBar('Ajoutez au moins un ingrédient pour continuer.');
      return;
    }

    if (!await _isOnline()) {
      if (!mounted) return;
      await ErrorDialog.show(
        context,
        title: 'Pas de connexion',
        message:
            'ChefAI nécessite une connexion internet pour générer des recettes. Vérifiez votre Wi-Fi ou vos données mobiles.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingLabel = '🤖 Création de la recette...';
    });

    try {
      final recipe = await ClaudeService().generateRecipe(
        ingredients: _ingredients,
        cuisine: _cuisineType,
        diet: _dietType,
        maxTime: _prepTime.round(),
      );

      if (!mounted) return;
      setState(() => _loadingLabel = '🎨 Génération de l\'image...');

      String imageUrl = '';
      try {
        imageUrl = await OpenAIService().generateRecipeImage(
          recipe.name,
          recipe.description,
        );
        debugPrint('✅ Image générée : $imageUrl');
      } catch (e) {
        debugPrint('❌ Image non générée : $e');
      }

      final fullRecipe = recipe.copyWith(imageUrl: imageUrl);
      await _historyService.addToHistory(fullRecipe);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeScreen(recipe: fullRecipe)),
      );
    } on ClaudeException catch (e) {
      if (!mounted) return;
      await ErrorDialog.show(
        context,
        title: 'Impossible de générer la recette',
        message:
            'Réessaie dans quelques instants.\n\nDétail : ${e.message}',
        actionLabel: 'Réessayer',
        onAction: _generateRecipe,
      );
    } catch (e) {
      if (!mounted) return;
      await ErrorDialog.show(
        context,
        title: 'Une erreur est survenue',
        message: e.toString(),
        actionLabel: 'Réessayer',
        onAction: _generateRecipe,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingLabel = '';
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: _textPrimary)),
        backgroundColor: _white,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: _lightBg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(),
                      const Gap(28),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(
                              text: 'Ingrédients disponibles',
                              icon: Icons.kitchen_rounded,
                            ),
                            const Gap(14),
                            IngredientInputField(
                              ingredients: _ingredients,
                              onChanged: (list) =>
                                  setState(() => _ingredients = list),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                      const Gap(16),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(
                              text: 'Type de cuisine',
                              icon: Icons.public_rounded,
                            ),
                            const Gap(12),
                            StyledDropdown<String>(
                              value: _cuisineType,
                              items: _cuisineTypes
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _cuisineType = v!),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const Gap(16),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(
                              text: 'Régime alimentaire',
                              icon: Icons.eco_rounded,
                            ),
                            const Gap(12),
                            StyledDropdown<String>(
                              value: _dietType,
                              items: _dietTypes
                                  .map((d) => DropdownMenuItem(
                                      value: d, child: Text(d)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _dietType = v!),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      const Gap(16),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionLabel(
                              text: 'Temps de préparation',
                              icon: Icons.timer_rounded,
                            ),
                            const Gap(12),
                            PrepTimeSlider(
                              value: _prepTime,
                              onChanged: (v) => setState(() => _prepTime = v),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const Gap(32),
                      _buildGenerateButton()
                          .animate()
                          .fadeIn(delay: 500.ms)
                          .slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Full-screen loading overlay
        if (_isLoading)
          Positioned.fill(
            child: LoadingOverlay(label: _loadingLabel),
          ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: _white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            tooltip: 'Historique',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _skyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _skyBlue.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.history_rounded,
                  color: _skyBlue, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_skyBlue, Color(0xFF0288D1)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _skyBlue.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'ChefAI',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        background: Container(color: _white),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _skyBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre chef personnel IA',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Gap(6),
          Text(
            'Dites-moi ce que vous avez dans votre frigo et je vous crée une recette sur mesure.',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.88),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05);
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 1),
        boxShadow: [
          BoxShadow(
            color: _skyBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _generateRecipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: _skyBlue,
          disabledBackgroundColor: _skyBlue.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: _skyBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 22, color: Colors.white),
            const Gap(10),
            Text(
              'Générer ma recette',
              style: GoogleFonts.playfairDisplay(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
