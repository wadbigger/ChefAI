import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';
import '../models/recipe_model.dart';
import '../services/history_service.dart';

const _skyBlue = Color(0xFF29B6F6);
const _lightBg = Color(0xFFF0F7FF);
const _white = Color(0xFFFFFFFF);
const _lightCard = Color(0xFFE8F4FD);
const _border = Color(0xFFCCE5F5);
const _textPrimary = Color(0xFF1A2E42);
const _textSecondary = Color(0xFF6B849A);

class RecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeScreen({super.key, required this.recipe});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final _historyService = HistoryService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final fav = await _historyService.isFavorite(widget.recipe.name);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    final nowFav = await _historyService.toggleFavorite(widget.recipe);
    if (!mounted) return;
    setState(() => _isFavorite = nowFav);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowFav ? '❤️ Ajouté aux favoris' : '💔 Retiré des favoris',
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: _textPrimary),
        ),
        backgroundColor: _white,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Recipe get r => widget.recipe;

  Color get _difficultyColor {
    switch (r.difficulty.toLowerCase()) {
      case 'facile':
        return const Color(0xFF2E7D32);
      case 'difficile':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF0277BD);
    }
  }

  Future<void> _share() async {
    final buf = StringBuffer()
      ..writeln('🍽️ ${r.name}')
      ..writeln()
      ..writeln(r.description)
      ..writeln()
      ..writeln(
          '⏱️ ${r.prepTime} min  •  👤 ${r.servings} pers.  •  📊 ${r.difficulty}')
      ..writeln()
      ..writeln('🛒 Ingrédients :');
    for (final ing in r.ingredients) {
      buf.writeln('  • $ing');
    }
    buf.writeln();
    buf.writeln('👨‍🍳 Préparation :');
    for (int i = 0; i < r.steps.length; i++) {
      buf.writeln('  ${i + 1}. ${r.steps[i]}');
    }
    buf.writeln();
    buf.writeln('Généré par ChefAI 🤖');
    await Share.share(buf.toString().trim(), subject: r.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHero(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickInfo(),
                      const Gap(24),
                      if (r.description.isNotEmpty) ...[
                        _buildDescription(),
                        const Gap(24),
                      ],
                      _buildIngredients(),
                      const Gap(24),
                      _buildSteps(),
                      const Gap(32),
                      _buildActions(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO ────────────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: _skyBlue,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      actions: [
        // Favorite button
        Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            onTap: _toggleFavorite,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isFavorite
                    ? const Color(0xFFE91E63).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite ? const Color(0xFFE91E63) : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        // Share button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: _share,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.share_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            r.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: r.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imageFallback(),
                  )
                : _imageFallback(),

            // Gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.2, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),

            // Title + badge
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DifficultyBadge(
                    label: r.difficulty,
                    color: _difficultyColor,
                  ),
                  const Gap(8),
                  Text(
                    r.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        const Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFB3E5FC),
      child: Center(
        child: CircularProgressIndicator(
          color: _skyBlue.withValues(alpha: 0.7),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 80,
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
    );
  }

  // ─── QUICK INFO ──────────────────────────────────────────────────────────

  Widget _buildQuickInfo() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.timer_outlined,
            value: '${r.prepTime}',
            unit: 'min',
            color: _skyBlue,
          ),
        ),
        const Gap(12),
        Expanded(
          child: _InfoCard(
            icon: Icons.people_outline_rounded,
            value: '${r.servings}',
            unit: 'pers.',
            color: const Color(0xFF26A69A),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _InfoCard(
            icon: Icons.bar_chart_rounded,
            value: r.difficulty,
            unit: '',
            color: _difficultyColor,
          ),
        ),
      ],
    );
  }

  // ─── DESCRIPTION ─────────────────────────────────────────────────────────

  Widget _buildDescription() {
    return _SectionCard(
      title: 'À propos',
      icon: Icons.auto_awesome_rounded,
      child: Text(
        r.description,
        style: GoogleFonts.lato(
          fontSize: 15,
          color: _textSecondary,
          height: 1.65,
        ),
      ),
    );
  }

  // ─── INGRÉDIENTS ─────────────────────────────────────────────────────────

  Widget _buildIngredients() {
    return _SectionCard(
      title: 'Ingrédients',
      icon: Icons.kitchen_rounded,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: _skyBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${r.ingredients.length} items',
          style: GoogleFonts.lato(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _skyBlue,
          ),
        ),
      ),
      child: Column(
        children:
            r.ingredients.map((ing) => _IngredientTile(ingredient: ing)).toList(),
      ),
    );
  }

  // ─── ÉTAPES ──────────────────────────────────────────────────────────────

  Widget _buildSteps() {
    return _SectionCard(
      title: 'Préparation',
      icon: Icons.format_list_numbered_rounded,
      child: Column(
        children: r.steps
            .asMap()
            .entries
            .map(
              (e) => _StepTile(
                number: e.key + 1,
                text: e.value,
                isLast: e.key == r.steps.length - 1,
              ),
            )
            .toList(),
      ),
    );
  }

  // ─── ACTIONS ─────────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Nouvelle recette',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _skyBlue,
              side: const BorderSide(color: _skyBlue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(
              'Partager',
              style: GoogleFonts.lato(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _skyBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: _skyBlue.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── WIDGETS ─────────────────────────────────────────────────────────────────

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DifficultyBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(6),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: GoogleFonts.lato(fontSize: 11, color: _textSecondary),
            ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _skyBlue.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _skyBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: _skyBlue, size: 16),
                  ),
                  const Gap(10),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              ?trailing,
            ],
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String ingredient;
  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _skyBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _skyBlue.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                ingredient,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: _textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _StepTile({
    required this.number,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_skyBlue, Color(0xFF0288D1)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _skyBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _skyBlue.withValues(alpha: 0.4),
                          _skyBlue.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: Text(
                  text.replaceFirst(RegExp(r'^Étape \d+[.:]\s*'), ''),
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: _textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
