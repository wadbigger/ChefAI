import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const _skyBlue = Color(0xFF29B6F6);
const _lightCard = Color(0xFFE8F4FD);
const _border = Color(0xFFCCE5F5);
const _textPrimary = Color(0xFF1A2E42);
const _textSecondary = Color(0xFF6B849A);

class IngredientChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const IngredientChip({
    super.key,
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      ),
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      deleteIconColor: _textSecondary,
      onDeleted: onDeleted,
      backgroundColor: _lightCard,
      side: const BorderSide(color: _skyBlue, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ).animate().fadeIn(duration: 200.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

class IngredientInputField extends StatefulWidget {
  final List<String> ingredients;
  final ValueChanged<List<String>> onChanged;

  const IngredientInputField({
    super.key,
    required this.ingredients,
    required this.onChanged,
  });

  @override
  State<IngredientInputField> createState() => _IngredientInputFieldState();
}

class _IngredientInputFieldState extends State<IngredientInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addIngredient() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.ingredients.contains(text)) {
      final updated = [...widget.ingredients, text];
      widget.onChanged(updated);
      _controller.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    final updated = widget.ingredients.where((i) => i != ingredient).toList();
    widget.onChanged(updated);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: _textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ex: poulet, tomates, basilic...',
                  prefixIcon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: _skyBlue,
                    size: 20,
                  ),
                ),
                onSubmitted: (_) {
                  _addIngredient();
                  _focusNode.requestFocus();
                },
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(width: 10),
            _AddButton(onPressed: _addIngredient),
          ],
        ),
        if (widget.ingredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: widget.ingredients
                .map(
                  (ingredient) => IngredientChip(
                    label: ingredient,
                    onDeleted: () => _removeIngredient(ingredient),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _skyBlue,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
