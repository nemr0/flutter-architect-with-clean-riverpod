import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:__APP__/presentation/core/gen/i18n/strings.g.dart';
import 'package:__APP__/presentation/core/routing/app_router.dart';
import 'package:__APP__/presentation/core/theme/app_theme.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';
// @imports

class App extends HookConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final appRouter = ref.watch(appRouterProvider);
    // @app-build

    return MaterialApp.router(
      // @title
      title: '__APP_TITLE__',
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      // ignore: prefer_const_literals_to_create_immutables — modules add to it.
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        // @delegates
      ],
      theme: theme.data,
      themeMode: theme.mode,
      routerConfig: appRouter.config(
        // @router-config
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // ignore: prefer_final_locals — modules wrap `app` at the marker below.
        var app = child!;
        // @app-builder
        return app;
      },
    );
  }
}
