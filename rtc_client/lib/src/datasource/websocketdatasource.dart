part of rtc_client;

/**
 * DataSource that uses websocket
 */
class WebSocketDataSource implements DataSource {
  /* Where do we connect */
  String _connectionString;
  
  /* Reference to the websocket connection */
  WebSocket _ws;
  
  /* DataSource event listeners */
  List<DataSourceEventListener> _listeners;
  
  /** Returns the current readystate for this datasource */
  int get readyState => getReadyState();
  
  /**
   * Constructor
   * Expects the connectionString as parameter
   * ie. ws://127.0.0.1/ws
   */
  WebSocketDataSource(String connectionString) {
    _connectionString = connectionString;
    _listeners = new List<DataSourceEventListener>();
  }
  
  /**
   * Initialize web socket connection and assign callbacks
   */
  void init() {
    _ws = new WebSocket(_connectionString);
    _ws.on.open.add(onOpen);  
    _ws.on.close.add(onClose);  
    _ws.on.error.add(onError);  
    _ws.on.message.add(onMessage);
  }
  
  /**
   * Returns the current readystate for this datasource
   */
  int getReadyState() {
    return _ws.readyState == WebSocket.OPEN ? DataSource.READYSTATE_OPEN : DataSource.READYSTATE_CLOSE;  
  }
  
  /**
   * Subscribe for datasource events
   */
  void subscribe(DataSourceEventListener l) {
    if (!_listeners.contains(l))
      _listeners.add(l);
  }
  
  /**
   * Send data over web socket
   */
  void send(String p) {
    _ws.send(p);
  }
  
  /**
   * Close the datasource
   */
  void close() {
    _ws.close(1000, "close");
  }
  
  /**
   * Send all messages received from callback to the datasource event listeners
   */
  void onMessage(MessageEvent e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onMessage(e.data);
    });
  }
  
  /**
   * Callback for websocket onopen
   * call the callback on datasource event listeners
   */
  void onOpen(Event e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onOpen("");
    });
  }
  
  /**
   * Callback for websocket onclose
   * call the callback on datasource event listeners
   */
  void onClose(CloseEvent e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onClose("${e.code.toString()} ${e.reason}");
    });
  }
  
  /**
   * Callback for websocket onerror
   * call the callback on datasource event listeners
   */
  void onError(Event e) {
    _listeners.filter((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onError("");
    });
  }
}
