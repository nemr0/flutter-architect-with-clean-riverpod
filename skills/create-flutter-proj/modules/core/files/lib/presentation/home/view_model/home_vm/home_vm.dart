import 'dart:async';

import 'package:__APP__/data/repositories/greeting_repository_impl/greeting_repository_impl.dart';
import 'package:__APP__/domain/model/greeting/greeting.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/helpers/normalize_to_app_error.dart';
import 'package:__APP__/presentation/core/mixins/app_effect_mixin.dart';
import 'package:__APP__/presentation/core/mixins/run_load_mixin.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_vm.g.dart';

/// The reference view model. State is the notifier's `AsyncValue` — no extra
/// state class, no try/catch. `guard` in build, `runLoad` in actions, `emit`
/// for one-shot UI.
@riverpod
class HomeVm extends _$HomeVm with AppEffectsMixin, RunLoadMixin {
  @override
  FutureOr<Greeting> build() =>
      guard(ref.read(greetingRepositoryProvider).getGreeting);

  Future<void> refresh() => runLoad(
    action: ref.read(greetingRepositoryProvider).getGreeting,
    apply: (status) => state = status,
    onSuccess: (_) => emit(.showSuccessSnackbar(t.home.refreshed)),
    onFailure: (error) => emit(.errorDialog(error)),
  );
}
