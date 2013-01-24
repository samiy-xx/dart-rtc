part of rtc_server_tests;

class TestableWebSocketConnection implements WebSocketConnection {
  Function _onMessage;
  Function _onClosed;
  
  set onMessage(m) => _onMessage = m;
  set onClosed(m) => _onClosed = m;
  
  dynamic close([int status, String reason]) {
    _onClosed(status, reason);
  }
  dynamic send(Object o) {
    _onMessage(o);
  }
}

