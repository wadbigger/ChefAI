import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import '../models/recipe_model.dart';
import '../services/history_service.dart';
import 'recipe_screen.dart';

const _skyBlue = Color(0xFF29B6F6);
const _lightBg = Color(0xFFF0F7FF);
const _white = Color(0xFFFFFFFF);
const _lightCard = Color(0xFFE8F4FD);
const _border = Color(0xFFCCE5F5);
const _textPrimary = Color(0xFF1A2E42);
const _textSecondary = Color(0xFF6B849A);

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = HistoryService();

  List<Recipe> _history = [];
  List<Recipe> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      _service.getHistory(),
      _service.getFavorites(),
    ]);
    if (!mounted) return;
    setState(() {
      _history = results[0];
      _favorites = results[1];
      _loading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Effacer l\'historique ?',
          style: GoogleFonts.playfairDisplay(
              color: _textPrimary, fontSize: 18),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: GoogleFonts.lato(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style: GoogleFonts.lato(color: _textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Effacer',
                style: GoogleFonts.lato(color: const Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _service.clearHistory();
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: _white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mes Recettes',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              tooltip: 'Effacer l\'historique',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: _textSecondary, size: 20),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _skyBlue,
          unselectedLabelColor: _textSecondary,
          indicatorColor: _skyBlue,
          indicatorWeight: 2.5,
          dividerColor: _border,
          labelStyle: GoogleFonts.lato(fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.lato(fontWeight: FontWeight.w500),
          tabs: [
            Tab(
              icon: const Icon(Icons.history_rounded, size: 18),
              text: 'Historique (${_history.length}/5)',
            ),
            Tab(
              icon: const Icon(Icons.favorite_rounded, size: 18),
              text: 'Favoris (${_favorites.length})',
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: _skyBlue),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_history,
                    emptyMessage:
                        'Aucune recette générée\npour l\'instant.'),
                _buildList(_favorites,
                    emptyMessage:
                        'Aucune recette en favori.\nAppuyez sur ❤️ pour en ajouter.'),
              ],
            ),
    );
  }

  Widget _buildList(List<Recipe> recipes, {required String emptyMessage}) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_rounded,
                size: 72, color: _skyBlue.withValues(alpha: 0.2)),
            const Gap(16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: _textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (_, i) => _RecipeCard(
        recipe: recipes[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeScreen(recipe: recipes[i]),
          ),
        ).then((_) => _load()),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeCard({required this.recipe, required this.onTap});

  Color get _diffColor {
    switch (recipe.difficulty.toLowerCase()) {
      case 'facile':
        return const Color(0xFF2E7D32);
      case 'difficile':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF0277BD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _skyBlue.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(17),
              ),
              child: SizedBox(
                width: 90,
                height: 90,
                child: recipe.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _placeholder(),
                        placeholder: (_, __) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 12, color: _textSecondary),
                        const Gap(3),
                        Text(
                          '${recipe.prepTime} min',
                          style: GoogleFonts.lato(
                              fontSize: 12, color: _textSecondary),
                        ),
                        const Gap(10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _diffColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _diffColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: _skyBlue.withValues(alpha: 0.5), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: _lightCard,
      child: Center(
        child: Icon(Icons.restaurant_rounded,
            color: _skyBlue.withValues(alpha: 0.25), size: 32),
      ),
    );
  }
}
