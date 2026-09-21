import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/theme/app_text_theme.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/theme/foundations/widget_effects.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';

/// Labeled text field over the theme's `inputDecorationTheme`. Specialized
/// fields (email, password, phone) wrap this with their validator + keyboard.
class PrimaryTextfield extends ConsumerWidget {
  const PrimaryTextfield({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.onSubmit,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final VoidCallback? onSubmit;
  final AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: .start,
    spacing: AppSpacings.s1_5,
    children: [
      if (label != null)
        Text(label!, style: ref.textTheme.textSm.medium()),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        autovalidateMode: autovalidateMode,
        onFieldSubmitted: onSubmit == null ? null : (_) => onSubmit!(),
        style: ref.textTheme.textMd,
        decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
      ),
    ],
  );
}
