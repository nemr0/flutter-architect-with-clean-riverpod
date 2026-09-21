import 'package:auto_route/auto_route.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:__APP__/data/util/error/app_error.dart';

part 'app_effect.freezed.dart';

/// One-shot UI outcomes a view model emits instead of folding into state.
/// Handled in exactly one place: `dispatch`. A new kind of effect = a new
/// factory here + a new `case` there.
@Freezed(equal: true, fromJson: false, toJson: false, copyWith: false)
sealed class AppEffect with _$AppEffect {
  const AppEffect._();

  const factory AppEffect.errorDialog(AppError error) = AppErrorDialogEffect;

  const factory AppEffect.navigate(PageRouteInfo route) = AppNavigateEffect;

  const factory AppEffect.replaceAll(List<PageRouteInfo> routes) =
      AppReplaceAllEffect;

  const factory AppEffect.pop({Object? result}) = AppPopEffect;

  const factory AppEffect.showSuccessSnackbar(String message) =
      AppShowSuccessSnackbarEffect;

  const factory AppEffect.popAndShowSuccessSnackbar(String message) =
      AppPopAndShowSuccessSnackbarEffect;
}
