import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

void showSuccessSnackbar(BuildContext context, {required String message}) {
  final colors = ProviderScope.containerOf(context).read(appThemeProvider).appColors;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: colors.success,
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
}
