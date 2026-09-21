// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/hooks/effects_hooks/dispatch.dart';
import 'package:__APP__/presentation/core/mixins/app_effect_mixin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Subscribes the widget to [provider]'s effect stream and routes every effect
/// through `dispatch`. Pass the generated provider itself:
///
/// ```dart
/// AsyncValue<void> useChangePasswordObserver(WidgetRef ref) {
///   useEffectsStream(ref, changePasswordVmProvider);
///   return ref.watch(changePasswordVmProvider);
/// }
/// ```
///
/// Watching `.notifier` keeps an auto-dispose provider alive while the widget
/// is mounted, so it isn't torn down mid-request (which would close the effect
/// stream before the result lands). Re-subscribes when the notifier installs a
/// new stream on rebuild. Call it before `ref.watch(provider)`.
void useEffectsStream<
  NotifierT extends AppEffectsMixin<StateT, ValueT>,
  StateT,
  ValueT
>(
  WidgetRef ref,
  // $ClassProvider is the only common supertype of the generated providers
  // that exposes `.notifier`; riverpod exports it for exactly this reason, but
  // still marks it internal.
  $ClassProvider<NotifierT, StateT, ValueT, Object?> provider,
) {
  final context = useContext();
  final effects = ref.watch(provider.notifier.select((e) => e.effects));
  useEffect(() {
    if (effects == null) return null;
    final subscription = effects.listen(
      // dispatch checks context.mounted itself.
      // ignore: use_build_context_synchronously
      (effect) => dispatch(ref, context, effect),
    );
    return subscription.cancel;
  }, [effects, provider]);
}
