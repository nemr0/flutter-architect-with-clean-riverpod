import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';
import 'package:__APP__/presentation/core/ui/providers/loading_state_view_model.dart';

/// Wrap a screen in this to get the global loading overlay that `runLoad`
/// drives. Grabs focus while loading so taps/keyboard can't reach the screen.
class ContainerWithLoading extends HookConsumerWidget {
  const ContainerWithLoading({super.key, required this.child, this.tag = 0});

  final Widget child;
  final int tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(
      loadingStateProvider.select(
        (s) => (on: s.isLoading && s.tag == tag, text: s.showLoadingText),
      ),
    );
    final focusNode = useFocusNode();
    useEffect(() {
      if (loading.on) focusNode.requestFocus();
      return null;
    }, [loading.on]);

    return Focus(
      focusNode: focusNode,
      child: Stack(
        children: [
          child,
          AnimatedSwitcher(
            duration: AppDurations.medium,
            child: loading.on
                ? _Overlay(showText: loading.text)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _Overlay extends ConsumerWidget {
  const _Overlay({required this.showText});
  final bool showText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    // Material, not Scaffold: a Scaffold here registers with the
    // ScaffoldMessenger, so a snackbar emitted as the load finishes attaches
    // to this overlay and vanishes with it.
    return Material(
      color: colors.gray200.withValues(alpha: .8),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: AppSpacings.s4,
          children: [
            CircularProgressIndicator(color: colors.brand),
            if (showText)
              Text(
                t.common.loadingPleaseWait,
                style: ref.textTheme.textMd.withColor(colors.gray700),
              ),
          ],
        ),
      ),
    );
  }
}
