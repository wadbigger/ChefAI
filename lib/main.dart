import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ChefAIApp());
}

class ChefAIApp extends StatelessWidget {
  const ChefAIApp({super.key});

  static const Color primaryBlue = Color(0xFF29B6F6);
  static const Color lightBg = Color(0xFFF0F7FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE8F4FD);
  static const Color border = Color(0xFFCCE5F5);
  static const Color textPrimary = Color(0xFF1A2E42);
  static const Color textSecondary = Color(0xFF6B849A);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: MaterialApp(
        title: 'ChefAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: lightBg,
          colorScheme: const ColorScheme.light(
            primary: primaryBlue,
            secondary: primaryBlue,
            surface: white,
            onPrimary: Colors.white,
            onSurface: textPrimary,
          ),
          textTheme: GoogleFonts.latoTextTheme(
            const TextTheme(
              bodyLarge: TextStyle(color: textPrimary),
              bodyMedium: TextStyle(color: textPrimary),
              bodySmall: TextStyle(color: textSecondary),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryBlue, width: 1.5),
            ),
            labelStyle: const TextStyle(color: textSecondary),
            hintStyle: const TextStyle(color: textSecondary),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: primaryBlue.withValues(alpha: 0.35),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: lightCard,
            selectedColor: primaryBlue.withValues(alpha: 0.2),
            labelStyle: const TextStyle(color: textPrimary),
            side: const BorderSide(color: border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: primaryBlue,
            thumbColor: primaryBlue,
            inactiveTrackColor: lightCard,
            overlayColor: primaryBlue.withValues(alpha: 0.15),
            valueIndicatorColor: primaryBlue,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            centerTitle: false,
            iconTheme: IconThemeData(color: textPrimary),
            titleTextStyle: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
