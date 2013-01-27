part of rtc_server_tests;

typedef void onWebsocketMessageType(String m);
typedef void onWebsocketCloseType(int status, String reason);

class TestableWebSocketConnection implements WebSocketConnection {
  onWebsocketMessageType _onMessage;
  onWebsocketCloseType _onClosed;
  
  set onMessage(onWebsocketMessageType m) => _onMessage = m;
  set onClosed(onWebsocketCloseType m) => _onClosed = m;
  
  dynamic close([int status, String reason]) {
    _onClosed(status, reason);
  }
  dynamic send(Object o) {
    _onMessage(o);
  }
}

