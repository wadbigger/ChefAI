import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _skyBlue = Color(0xFF29B6F6);
const _white = Color(0xFFFFFFFF);
const _lightCard = Color(0xFFE8F4FD);
const _border = Color(0xFFCCE5F5);
const _textPrimary = Color(0xFF1A2E42);
const _textSecondary = Color(0xFF6B849A);

class SectionLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const SectionLabel({super.key, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _skyBlue, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: _white,
        style: GoogleFonts.lato(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _skyBlue),
      ),
    );
  }
}

class PrepTimeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const PrepTimeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _formatTime(double minutes) {
    if (minutes < 60) return '${minutes.round()} min';
    final h = (minutes / 60).floor();
    final m = (minutes % 60).round();
    return m == 0 ? '${h}h' : '${h}h${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '15 min',
              style: GoogleFonts.lato(
                  fontSize: 12, color: _textSecondary),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _skyBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _skyBlue.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                _formatTime(value),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _skyBlue,
                ),
              ),
            ),
            Text(
              '2h',
              style: GoogleFonts.lato(
                  fontSize: 12, color: _textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Slider(
          value: value,
          min: 15,
          max: 120,
          divisions: 21,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
