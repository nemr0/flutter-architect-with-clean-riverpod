import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/theme/app_colors.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

enum ButtonVariant { primary, secondary, tertiary }

/// The app's only button. Pick a variant via the named constructors; add a
/// variant here rather than styling a Material button in a screen.
class Button extends ConsumerWidget {
  const Button.primary({
    super.key,
    required this.onPressed,
    required this.title,
    this.leading,
    this.expanded = true,
  }) : variant = ButtonVariant.primary;

  const Button.secondary({
    super.key,
    required this.onPressed,
    required this.title,
    this.leading,
    this.expanded = true,
  }) : variant = ButtonVariant.secondary;

  const Button.tertiary({
    super.key,
    required this.onPressed,
    required this.title,
    this.leading,
    this.expanded = false,
  }) : variant = ButtonVariant.tertiary;

  final ButtonVariant variant;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final String title;
  final Widget? leading;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.colors;
    final (bg, fg, border) = _palette(colors);
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expanded ? double.infinity : 0, 52),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: AppSpacings.s5),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) ? colors.gray200 : bg,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) ? colors.gray500 : fg,
      ),
      side: WidgetStatePropertyAll(
        border == null ? BorderSide.none : BorderSide(color: border),
      ),
      textStyle: WidgetStatePropertyAll(ref.textTheme.textMd.semiBold()),
      elevation: const WidgetStatePropertyAll(0),
    );
    return TextButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: .min,
        spacing: AppSpacings.s2,
        children: [?leading, Text(title)],
      ),
    );
  }

  (Color, Color, Color?) _palette(AppColors c) => switch (variant) {
    ButtonVariant.primary => (c.brand, Colors.white, null),
    ButtonVariant.secondary => (c.background, c.text, c.gray300),
    ButtonVariant.tertiary => (Colors.transparent, c.brand, null),
  };
}
