import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';
// @imports

import 'app.dart';

// @run
void main() => _bootstrap();

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // @bootstrap
  LocaleSettings.useDeviceLocale();

  runApp(
    ProviderScope(
      // ignore: prefer_const_literals_to_create_immutables — modules add to it.
      observers: [
        // @observers
      ],
      child: TranslationProvider(child: const App()),
    ),
  );
}
