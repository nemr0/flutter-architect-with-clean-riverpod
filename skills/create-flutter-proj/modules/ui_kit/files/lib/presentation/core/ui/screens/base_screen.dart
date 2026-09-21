import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Every full screen starts here: themed background, a scrolling
/// title/subtitle header, side padding, and an optional pinned [bottomBar]
/// (composer, CTA) that rides the keyboard.
class BaseScreen extends HookConsumerWidget {
  const BaseScreen({
    super.key,
    this.title,
    this.subtitle,
    this.onLeadingPressed,
    this.onTrailingPressed,
    this.body,
    this.slivers,
    this.bottomBar,
    this.sidePadding = AppSpacings.s5,
    this.canPop = true,
  }) : assert(
         (body != null) ^ (slivers != null),
         'Provide exactly one of body or slivers.',
       );

  final String? title;
  final String? subtitle;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTrailingPressed;

  /// A box widget; fills the remaining height (so `Spacer` works).
  final Widget? body;

  /// Slivers, added straight to the scroll view.
  final List<Widget>? slivers;
  final Widget? bottomBar;
  final double sidePadding;
  final bool canPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    final padding = EdgeInsets.symmetric(horizontal: sidePadding);
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: onLeadingPressed == null && onTrailingPressed == null
            ? null
            : AppBar(
                backgroundColor: colors.background,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: onLeadingPressed == null
                    ? null
                    : IconButton(
                        onPressed: onLeadingPressed,
                        icon: const Icon(Icons.arrow_back),
                      ),
                actions: [
                  if (onTrailingPressed != null)
                    IconButton(
                      onPressed: onTrailingPressed,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
        bottomNavigationBar: bottomBar == null
            ? null
            : SafeArea(
                child: Padding(
                  padding: padding.copyWith(bottom: AppSpacings.s4),
                  child: bottomBar,
                ),
              ),
        body: SafeArea(
          bottom: bottomBar == null,
          child: CustomScrollView(
            slivers: [
              if (title != null)
                SliverPadding(
                  padding: padding.copyWith(
                    top: AppSpacings.s4,
                    bottom: AppSpacings.s2,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      title!,
                      style: ref.textTheme.displayXs.bold(),
                    ),
                  ),
                ),
              if (subtitle != null)
                SliverPadding(
                  padding: padding.copyWith(bottom: AppSpacings.s6),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      subtitle!,
                      style: ref.textTheme.textMd.withColor(colors.subText),
                    ),
                  ),
                ),
              if (slivers != null)
                for (final s in slivers!)
                  SliverPadding(padding: padding, sliver: s)
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: padding.copyWith(bottom: AppSpacings.s4),
                    child: body,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
