import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:__APP__/domain/event/event_bus.dart';
import 'package:__APP__/domain/event/session_event.dart';
import 'package:__APP__/presentation/core/routing/app_router.dart';

extension RouterRedirection on AppRouter {
  /// Called once from `App.build`. Reacts to session events fired from the
  /// data layer (e.g. the refresh interceptor giving up).
  StreamSubscription<SessionEvent>? useSessionForceRedirection() =>
      useOnStreamChange(
        eventBus.on<SessionEvent>(),
        onData: (event) {
          switch (event.type) {
            case SessionEventType.forceLogout:
              // TODO: replace with your LoginRoute once it exists.
              replaceAll([const HomeRoute()]);
            case SessionEventType.forceUpdate:
              break;
          }
        },
      );
}
