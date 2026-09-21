import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/domain/model/greeting/greeting.dart';
import 'package:__APP__/presentation/core/hooks/effects_hooks/use_effects_stream.dart';
import 'package:__APP__/presentation/home/view_model/home_vm/home_vm.dart';

/// Screens call this, never `effects` directly. Effects first, then watch.
AsyncValue<Greeting> useHomeObserver(WidgetRef ref) {
  useEffectsStream(ref, homeVmProvider);
  return ref.watch(homeVmProvider);
}
