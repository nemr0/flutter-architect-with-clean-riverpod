import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:__APP__/data/repositories/greeting_repository_impl/greeting_repository_impl.dart';
import 'package:__APP__/data/util/error/app_error.dart';
import 'package:__APP__/domain/model/greeting/greeting.dart';
import 'package:__APP__/domain/repositories/greeting_repository.dart';
import 'package:__APP__/presentation/core/state/app_effect.dart';
import 'package:__APP__/presentation/home/view_model/home_vm/home_vm.dart';

class _MockRepo extends Mock implements GreetingRepository {}

void main() {
  // The template for every view model test: override the repository
  // provider, drive the VM, assert on state + emitted effects.
  test('a failing refresh lands as AppError state and an errorDialog effect',
      () async {
    final repo = _MockRepo();
    when(repo.getGreeting)
        .thenAnswer((_) async => const Greeting(message: 'hi', count: 1));
    final container = ProviderContainer(
      overrides: [greetingRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(homeVmProvider, (_, _) {});
    addTearDown(sub.close);
    expect(await container.read(homeVmProvider.future),
        const Greeting(message: 'hi', count: 1));

    final effects = <AppEffect>[];
    container.read(homeVmProvider.notifier).effects!.listen(effects.add);

    when(repo.getGreeting).thenThrow(StateError('boom'));
    await container.read(homeVmProvider.notifier).refresh();

    expect(container.read(homeVmProvider).error, isA<AppError>());
    expect(effects.single, isA<AppErrorDialogEffect>());
  });
}
