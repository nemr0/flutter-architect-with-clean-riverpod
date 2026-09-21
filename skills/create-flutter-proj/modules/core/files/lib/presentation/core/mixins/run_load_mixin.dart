import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/data/util/error/app_error.dart';
import 'package:__APP__/presentation/core/ui/providers/loading_state_view_model.dart';

/// Async plumbing shared by generated view models: [runLoad], the standard
/// "loading → data | error" transition. View models never try/catch.
///
/// ```dart
/// Future<void> save() => runLoad(
///       action: () => ref.read(fooRepositoryProvider).save(),
///       apply: (s) => state = s,
///       onSuccess: (_) => emit(const AppEffect.pop()),
///       onFailure: (e) => emit(AppEffect.errorDialog(e)),
///     );
/// ```
mixin RunLoadMixin<T, E> on AnyNotifier<T, E> {
  /// Flow: [onLoading], `AsyncValue.loading()`; on success `.data(value)` then
  /// [onSuccess]; on throw [onFailure] then `.error(appError)`. Anything thrown
  /// arrives as an [AppError].
  ///
  /// [apply] is normally `(s) => state = s`; pass a narrower setter when the
  /// notifier holds several independent loads in one state object.
  ///
  /// Never throws. If the notifier is disposed mid-flight the terminal `apply`
  /// is skipped (`ref.mounted`) but [onSuccess]/[onFailure] still run.
  ///
  /// [useLoadingProvider] toggles the global [loadingStateProvider] (the
  /// full-screen `ContainerWithLoading` overlay). Turn it off for background
  /// refreshes that should stay scoped to the screen.
  Future<void> runLoad<S>({
    required Future<S> Function() action,
    required void Function(AsyncValue<S> status) apply,
    void Function()? onLoading,
    bool useLoadingProvider = true,
    void Function(S value)? onSuccess,
    void Function(AppError error)? onFailure,
  }) async {
    onLoading?.call();

    final loadingNotifier = useLoadingProvider
        ? ref.read(loadingStateProvider.notifier)
        : null;
    loadingNotifier?.toLoading();

    apply(const .loading());
    try {
      final value = await action();
      if (!ref.mounted) return;
      apply(.data(value));
      onSuccess?.call(value);
    } catch (e, s) {
      final error = AppError.fromException(e, trace: s);
      onFailure?.call(error);
      if (!ref.mounted) return;
      apply(.error(error, s));
    } finally {
      loadingNotifier?.toIdle();
    }
  }
}
