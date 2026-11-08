import 'dart:async';

import '../storage/token_storage.dart';

sealed class SessionEvent {
  const SessionEvent();
}

class SessionExpired extends SessionEvent {
  const SessionExpired();
}

class SessionEnded extends SessionEvent {
  const SessionEnded();
}

/// Central owner of authentication lifecycle events.
///
/// A single HTTP 401 clears the session only once, even when several requests
/// fail concurrently, and emits exactly one event so the app navigates to login
/// without endless redirects.
class SessionManager {
  final TokenStorage tokenStorage;
  final StreamController<SessionEvent> _events =
      StreamController<SessionEvent>.broadcast();

  bool _expiring = false;

  SessionManager(this.tokenStorage);

  Stream<SessionEvent> get events => _events.stream;

  Future<bool> hasSession() async {
    final token = await tokenStorage.getToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<void> expireSession() async {
    if (_expiring) return;
    _expiring = true;
    try {
      final hadSession = await hasSession();
      await tokenStorage.clearSession();
      if (hadSession) _events.add(const SessionExpired());
    } finally {
      _expiring = false;
    }
  }

  Future<void> logout() async {
    await tokenStorage.clearSession();
    _events.add(const SessionEnded());
  }

  Future<void> dispose() => _events.close();
}
