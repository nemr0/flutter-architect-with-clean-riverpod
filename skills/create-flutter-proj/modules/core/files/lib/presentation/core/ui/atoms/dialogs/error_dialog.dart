import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/hooks/use_translation.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

bool _isErrorDialogShowing = false;

/// Single-instance: several failing loads at once show one dialog, not a stack.
Future<void> showErrorDialog(BuildContext context, String message) async {
  if (_isErrorDialogShowing) return;
  _isErrorDialogShowing = true;
  try {
    await showDialog<void>(
      context: context,
      builder: (context) => ErrorDialog(message: message),
    );
  } finally {
    _isErrorDialogShowing = false;
  }
}

class ErrorDialog extends HookConsumerWidget {
  const ErrorDialog({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = useTranslation();
    final colors = ref.colors;
    final textTheme = ref.textTheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
      ),
      icon: Icon(Icons.info_outline, size: 56, color: colors.danger),
      backgroundColor: colors.background,
      title: Text(
        t.commonExceptions.somethingWrong,
        style: textTheme.textXL.bold(),
        textAlign: TextAlign.center,
      ),
      content: Text(
        message,
        style: textTheme.textMd,
        textAlign: TextAlign.center,
      ),
      actions: [
        FilledButton(
          onPressed: context.router.maybePop,
          child: Text(t.common.closeButton),
        ),
      ],
    );
  }
}
