import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/state/app_effect.dart';

/// Adds a broadcast stream of one-shot UI effects to a generated view model.
///
/// Mix into a `@riverpod` notifier that fires side effects the UI consumes
/// once and forgets — navigation, snackbars, dialogs — instead of folding them
/// into `state`. The UI subscribes via `useEffectsStream`; the view model
/// fires with [emit]. No `BuildContext` in a view model, ever.
///
/// Lifecycle: the controller is created at the top of every [runBuild] —
/// before `super.runBuild()`, so effects emitted from `build` itself are valid
/// — and closed by a `ref.onDispose` registered in the same pass. Riverpod 3
/// reuses the notifier across `invalidate`/`refresh` and runs dispose
/// callbacks on each rebuild, so controller and hook are paired one-per-build.
/// The UI must re-subscribe after every rebuild (`useEffectsStream` does).
///
/// Broadcast semantics: emissions with no listener are dropped, not buffered.
/// Anything the UI must be able to read late belongs in `state`.
mixin AppEffectsMixin<T, E> on AnyNotifier<T, E> {
  StreamController<AppEffect>? _controller;

  /// Null before the first build and after disposal.
  Stream<AppEffect>? get effects => _controller?.stream;

  /// A no-op when no controller is open, so callers don't have to guard
  /// against a torn-down notifier.
  void emit(AppEffect effect) {
    if (_controller?.isClosed != false) return;
    _controller?.add(effect);
  }

  @override
  void runBuild() {
    _controller = StreamController.broadcast();
    ref.onDispose(_disposeEffectController);
    super.runBuild();
  }

  void _disposeEffectController() {
    if (_controller?.isClosed == false) _controller?.close();
  }
}
