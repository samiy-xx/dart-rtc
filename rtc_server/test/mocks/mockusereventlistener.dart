part of rtc_server_tests;

typedef void onUserConnectionClosedCallback(User u, int status, String reason);

class MockUserEventListener implements UserConnectionEventListener {
  onUserConnectionClosedCallback _onConnectionClose;
  
  set onConnectionClose(onUserConnectionClosedCallback cb) => _onConnectionClose = cb;
  
  void onClose(User u, int status, String reason) {
    if (_onConnectionClose != null)
      _onConnectionClose(u, status, reason);
  }
}

