import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';

/// Pure `String? Function(String?)` validators — compose with [all].
/// Messages come from `t.validation`, never literals.
abstract final class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? t.validation.required : null;

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static String? email(String? v) =>
      required(v) ?? (_email.hasMatch(v!.trim()) ? null : t.validation.invalidEmail);

  static String? Function(String?) minLength(int min) => (v) =>
      required(v) ??
      (v!.length < min ? t.validation.passwordTooShort(min: min) : null);

  /// First failing validator wins.
  static String? Function(String?) all(List<String? Function(String?)> vs) =>
      (v) {
        for (final validate in vs) {
          final error = validate(v);
          if (error != null) return error;
        }
        return null;
      };
}
