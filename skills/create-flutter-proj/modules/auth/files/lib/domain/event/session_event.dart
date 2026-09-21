enum SessionEventType { forceLogout, forceUpdate }

class SessionEvent {
  const SessionEvent({required this.type});
  final SessionEventType type;
}
