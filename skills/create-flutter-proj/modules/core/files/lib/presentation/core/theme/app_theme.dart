import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/theme/app_colors.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Read theme tokens in widgets through these, never `Color(0x…)` or a raw
/// `TextStyle` in a screen:
/// `ref.colors.brand`, `ref.textTheme.textMd.bold()`.
extension ThemeExtension on WidgetRef {
  AppTheme get theme => watch(appThemeProvider);
  AppColors get colors => watch(appThemeProvider.select((e) => e.appColors));
  AppTextTheme get textTheme =>
      watch(appThemeProvider.select((e) => e.textTheme));
}

final appThemeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle() => state = state == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

final appThemeProvider = Provider<AppTheme>(
  (ref) => switch (ref.watch(appThemeModeProvider)) {
    ThemeMode.dark => AppTheme._build(ThemeMode.dark, AppColors.dark()),
    _ => AppTheme._build(ThemeMode.light, AppColors.light()),
  },
);

class AppTheme {
  AppTheme({
    required this.mode,
    required this.data,
    required this.textTheme,
    required this.appColors,
  });

  factory AppTheme._build(ThemeMode mode, AppColors colors) {
    final textTheme = AppTextTheme(colors.text);
    OutlineInputBorder border(Color c, {double width = 1}) =>
        OutlineInputBorder(
          borderSide: BorderSide(color: c, width: width),
          borderRadius: BorderRadius.circular(AppRadii.xl),
        );
    final base = mode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light();
    final data = base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.brand,
        brightness: mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      ),
      primaryColor: colors.brand,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(color: colors.gray200, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(AppSpacings.s3),
        enabledBorder: border(colors.gray200),
        focusedBorder: border(colors.brand, width: 2),
        errorBorder: border(colors.danger),
        focusedErrorBorder: border(colors.danger, width: 2),
        disabledBorder: border(colors.gray100),
        filled: true,
        fillColor: colors.surface,
        hintStyle: textTheme.textSm.withColor(colors.hintText),
        errorStyle: textTheme.textXs.semiBold().withColor(colors.danger),
      ),
    );
    return AppTheme(
      mode: mode,
      data: data,
      textTheme: textTheme,
      appColors: colors,
    );
  }

  final ThemeMode mode;
  final ThemeData data;
  final AppTextTheme textTheme;
  final AppColors appColors;
}
