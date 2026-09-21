import 'package:event_bus/event_bus.dart';

/// App-wide bus for the few signals with no owner in the widget tree
/// (force-logout, force-update). Anything a provider or an `AppEffect` can
/// express belongs there instead — this is a deliberate escape hatch.
final eventBus = EventBus();
