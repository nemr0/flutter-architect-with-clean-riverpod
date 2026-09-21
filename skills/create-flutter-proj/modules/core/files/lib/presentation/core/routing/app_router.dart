import 'package:auto_route/auto_route.dart';
import 'package:__APP__/presentation/core/ui/exports/material_export.dart';
import 'package:__APP__/presentation/home/screens/home_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.gr.dart';
part 'app_router.g.dart';

/// keepAlive: the router owns the navigation stack for the app's life;
/// an auto-dispose router would drop the stack the moment nothing watches it.
@Riverpod(keepAlive: true)
AppRouter appRouter(Ref ref) => AppRouter();

/// Every `@RoutePage()` screen is registered here; `XRoute` classes are
/// generated into `app_router.gr.dart`.
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter() : super(navigatorKey: rootNavigatorKey);

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: HomeRoute.page, initial: true),
  ];
}
