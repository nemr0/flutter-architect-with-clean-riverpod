import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/atoms/buttons/button/button.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Yes/no confirmation. Resolves `true` only on confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText ?? t.common.confirmButton,
      ),
    ) ??
    false;

/// Same, as a bottom sheet — preferred on phones for destructive actions.
Future<bool> showConfirmBottomSheet(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmText,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: _ConfirmBody(
          title: title,
          message: message,
          confirmText: confirmText ?? t.common.confirmButton,
        ),
      ),
    ) ??
    false;

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
  });
  final String title, message, confirmText;

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.xxl),
    ),
    child: _ConfirmBody(
      title: title,
      message: message,
      confirmText: confirmText,
    ),
  );
}

class _ConfirmBody extends ConsumerWidget {
  const _ConfirmBody({
    required this.title,
    required this.message,
    required this.confirmText,
  });
  final String title, message, confirmText;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.all(AppSpacings.s6),
    child: Column(
      mainAxisSize: .min,
      spacing: AppSpacings.s3,
      children: [
        Text(title, style: ref.textTheme.textXL.bold(), textAlign: .center),
        Text(
          message,
          style: ref.textTheme.textMd.withColor(ref.colors.subText),
          textAlign: .center,
        ),
        const SizedBox(height: AppSpacings.s2),
        Button.primary(
          onPressed: () => context.router.maybePop(true),
          title: confirmText,
        ),
        Button.secondary(
          onPressed: () => context.router.maybePop(false),
          title: t.common.cancelButton,
        ),
      ],
    ),
  );
}
