import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/util/error/app_error.dart';
import 'package:__APP__/presentation/core/state/app_effect.dart';
import 'package:__APP__/presentation/core/ui/atoms/dialogs/error_dialog.dart';
import 'package:__APP__/presentation/core/ui/atoms/snackbars/success_snackbar.dart';

/// Turns an [AppEffect] into UI. The only place that knows both the effect
/// types and the widget tree, so view models stay UI-agnostic.
@protected
void dispatch(WidgetRef ref, BuildContext context, AppEffect effect) {
  if (!context.mounted) return;
  switch (effect) {
    case AppErrorDialogEffect(:final error):
      // A user backing out of a flow is not an error worth a dialog.
      if (error.type == AppErrorType.cancel) return;
      showErrorDialog(context, error.message);
    case AppNavigateEffect(:final route):
      context.router.push(route);
    case AppReplaceAllEffect(:final routes):
      context.router.replaceAll(routes);
    case AppPopEffect(:final result):
      context.router.maybePop(result);
    case AppShowSuccessSnackbarEffect(:final message):
      showSuccessSnackbar(context, message: message);
    case AppPopAndShowSuccessSnackbarEffect(:final message):
      context.router.maybePop();
      showSuccessSnackbar(context, message: message);
  }
}
