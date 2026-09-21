import 'package:__APP__/presentation/core/theme/font_size.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Design-system type scale, also mapped onto Material's slots so stock
/// widgets pick it up. Use `ref.textTheme.textMd.bold().withColor(...)`.
class AppTextTheme extends TextTheme {
  const AppTextTheme._({
    required this.textXs,
    required this.textSm,
    required this.textMd,
    required this.textLg,
    required this.textXL,
    required this.displayXs,
    required this.displaySm,
    required this.displayMd,
    required this.displayLg,
  }) : super(
         displayLarge: displayLg,
         displayMedium: displayMd,
         displaySmall: displaySm,
         headlineSmall: displayXs,
         titleLarge: textXL,
         titleMedium: textLg,
         titleSmall: textMd,
         bodyLarge: textMd,
         bodyMedium: textSm,
         bodySmall: textXs,
         labelLarge: textSm,
         labelMedium: textXs,
         labelSmall: textXs,
       );

  factory AppTextTheme(Color textColor) {
    final base = TextStyle(color: textColor).regular();
    TextStyle size(double s, [double? h]) =>
        TextStyle(fontSize: s, height: h).merge(base);
    return AppTextTheme._(
      textXs: size(FontSize.pt12),
      textSm: size(FontSize.pt14),
      textMd: size(FontSize.pt16, 1.4),
      textLg: size(FontSize.pt18),
      textXL: size(FontSize.pt20),
      displayXs: size(FontSize.pt24),
      displaySm: size(FontSize.pt28),
      displayMd: size(FontSize.pt32),
      displayLg: size(FontSize.pt44, 1.3),
    );
  }

  final TextStyle textXs;
  final TextStyle textSm;
  final TextStyle textMd;
  final TextStyle textLg;
  final TextStyle textXL;
  final TextStyle displayXs;
  final TextStyle displaySm;
  final TextStyle displayMd;
  final TextStyle displayLg;
}

extension TextStyleExt on TextStyle {
  TextStyle extraBold() => copyWith(fontWeight: FontWeight.w800);
  TextStyle bold() => copyWith(fontWeight: FontWeight.w700);
  TextStyle semiBold() => copyWith(fontWeight: FontWeight.w600);
  TextStyle medium() => copyWith(fontWeight: FontWeight.w500);
  TextStyle regular() => copyWith(fontWeight: FontWeight.w400);
  TextStyle light() => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
}
