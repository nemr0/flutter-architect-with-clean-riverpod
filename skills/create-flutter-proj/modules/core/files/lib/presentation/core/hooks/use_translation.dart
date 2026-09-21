import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';

/// Locale-reactive translations inside a hook widget. Outside widgets, use
/// the global `t`.
Translations useTranslation() {
  final context = useContext();
  final translations = Translations.of(context);
  return useMemoized(() => translations, [translations]);
}
