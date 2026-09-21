import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Semantic color tokens. Add a token here (both factories) before using a
/// new color anywhere; screens never hold a literal `Color`.
class AppColors {
  const AppColors({
    required this.background,
    required this.surface,
    required this.text,
    required this.subText,
    required this.hintText,
    required this.brand,
    required this.brandLight,
    required this.gray100,
    required this.gray200,
    required this.gray300,
    required this.gray500,
    required this.gray700,
    required this.danger,
    required this.dangerLight,
    required this.success,
    required this.successLight,
  });

  factory AppColors.light() => const AppColors(
    background: Colors.white,
    surface: .new(0xFFF8FAFB),
    text: .new(0xFF222831),
    subText: .new(0xFF7B879B),
    hintText: .new(0xFFA1AEB7),
    brand: .new(0xFF2563EB),
    brandLight: .new(0xFFEFF4FF),
    gray100: .new(0xFFF0F4F6),
    gray200: .new(0xFFE5EBEF),
    gray300: .new(0xFFC2D1D9),
    gray500: .new(0xFF7B879B),
    gray700: .new(0xFF2F3743),
    danger: .new(0xFFD62A2A),
    dangerLight: .new(0xFFFFF4F4),
    success: .new(0xFF1F9D55),
    successLight: .new(0xFFF0FBF4),
  );

  factory AppColors.dark() => const AppColors(
    background: .new(0xFF1C1C1E),
    surface: .new(0xFF2A2A2D),
    text: .new(0xFFEDEFF2),
    subText: .new(0xFF9AA3B2),
    hintText: .new(0xFF6B7280),
    brand: .new(0xFF5B8DEF),
    brandLight: .new(0xFF14223F),
    gray100: .new(0xFF26262A),
    gray200: .new(0xFF2F2F34),
    gray300: .new(0xFF3A3A40),
    gray500: .new(0xFF9AA3B2),
    gray700: .new(0xFFE5E7EB),
    danger: .new(0xFFE5484D),
    dangerLight: .new(0xFF3A1A1A),
    success: .new(0xFF34C759),
    successLight: .new(0xFF152A1A),
  );

  final Color background;
  final Color surface;
  final Color text;
  final Color subText;
  final Color hintText;
  final Color brand;
  final Color brandLight;
  final Color gray100;
  final Color gray200;
  final Color gray300;
  final Color gray500;
  final Color gray700;
  final Color danger;
  final Color dangerLight;
  final Color success;
  final Color successLight;
}
