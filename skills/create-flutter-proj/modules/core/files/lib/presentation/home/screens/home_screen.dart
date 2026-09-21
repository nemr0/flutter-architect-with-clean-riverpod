import 'package:auto_route/auto_route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/atoms/loading/container_with_loading.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';
import 'package:__APP__/presentation/core/ui/screens/error_screen.dart';
import 'package:__APP__/presentation/home/hooks/use_home_observer.dart';
import 'package:__APP__/presentation/home/view_model/home_vm/home_vm.dart';

@RoutePage()
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useHomeObserver(ref);
    return ContainerWithLoading(
      child: Scaffold(
        appBar: AppBar(title: Text(t.home.title)),
        body: state.when(
          // Keep showing the last value while runLoad refreshes; the overlay
          // covers the loading state.
          skipLoadingOnRefresh: true,
          skipLoadingOnReload: true,
          data: (greeting) => Center(
            child: Column(
              mainAxisSize: .min,
              spacing: AppSpacings.s2,
              children: [
                Text(greeting.message, style: ref.textTheme.textXL.bold()),
                Text(
                  '${greeting.count}',
                  key: const Key('greeting-count'),
                  style: ref.textTheme.displayMd.withColor(ref.colors.brand),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorScreen(
            error: error,
            onRetry: () => ref.invalidate(homeVmProvider),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: ref.read(homeVmProvider.notifier).refresh,
          label: Text(t.home.refresh),
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
