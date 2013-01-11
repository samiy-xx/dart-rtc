part of rtc_client;

class WebSocketDataSource implements DataSource {
  String _connectionString;
  WebSocket _ws;
  List<DataSourceEventListener> _listeners;
  
  int get readyState => getReadyState();
  
  WebSocketDataSource(String c) {
    _connectionString = c;
    _listeners = new List<DataSourceEventListener>();
  }
  
  void init() {
    _ws = new WebSocket(_connectionString);
    _ws.on.open.add(onOpen);  
    _ws.on.close.add(onClose);  
    _ws.on.error.add(onError);  
    _ws.on.message.add(onMessage);
  }
  
  int getReadyState() {
    return _ws.readyState == WebSocket.OPEN ? DataSource.READYSTATE_OPEN : DataSource.READYSTATE_CLOSE;  
  }
  
  void subscribe(DataSourceEventListener l) {
    if (!_listeners.contains(l))
      _listeners.add(l);
  }
  
  void send(String p) {
    _ws.send(p);
  }
  
  void close() {
    _ws.close(1000, "close");
  }
  
  void onMessage(MessageEvent e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onMessage(e.data);
    });
  }
  /**
   * Callback for websocket onopen
   */
  void onOpen(Event e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onOpen("");
    });
  }
  
  /**
   * Callback for websocket onclose
   */
  void onClose(CloseEvent e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onClose("${e.code.toString()} ${e.reason}");
    });
  }
  
  /**
   * Callback for websocket onerror
   */
  void onError(Event e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onError("");
    });
  }
}
