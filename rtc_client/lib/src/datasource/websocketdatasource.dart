part of rtc_client;

/**
 * DataSource that uses websocket
 * Extends GenericEventTarget for dispatching events
 */
class WebSocketDataSource extends GenericEventTarget<DataSourceEventListener> implements DataSource {
  /* Where do we connect */
  String _connectionString;
  
  /* Reference to the websocket connection */
  WebSocket _ws;
  
  /** Returns the current readystate for this datasource */
  int get readyState => getReadyState();
  
  /**
   * Constructor
   * Expects the connectionString as parameter
   * ie. ws://127.0.0.1/ws
   */
  WebSocketDataSource(String connectionString) : super(){
    _connectionString = connectionString;
  }
  
  /**
   * Initialize web socket connection and assign callbacks
   */
  void init() {
    _ws = new WebSocket(_connectionString);
    _ws.onOpen.listen(onOpen);  
    _ws.onClose.listen(onClose);  
    _ws.onError.listen(onError);  
    _ws.onMessage.listen(onMessage);
  }
  
  /**
   * Returns the current readystate for this datasource
   */
  int getReadyState() {
    return _ws.readyState == WebSocket.OPEN ? DataSource.READYSTATE_OPEN : DataSource.READYSTATE_CLOSE;  
  }
  
  /**
   * Send data over web socket
   */
  void send(String p) {
    _ws.send(p);
  }
  
  void sendArrayBuffer(ArrayBuffer buf) {
    throw new UnimplementedError("Sending ArrayBuffer is not implemented");
  }
  
  /**
   * Close the datasource
   */
  void close() {
    _ws.close(1000, "close");
  }
  
  /**
   * Callback for websocket onMessage
   * Send all messages received from callback to the datasource event listeners
   */
  void onMessage(MessageEvent e) {
    listeners.where((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onDataSourceMessage(e.data);
    });
  }
  
  /**
   * Callback for websocket onopen
   * call the callback on datasource event listeners
   */
  void onOpen(Event e) {
    listeners.where((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onOpenDataSource("");
    });
  }
  
  /**
   * Callback for websocket onclose
   * call the callback on datasource event listeners
   */
  void onClose(CloseEvent e) {
    listeners.where((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onCloseDataSource("${e.code.toString()} ${e.reason}");
    });
  }
  
  /**
   * Callback for websocket onerror
   * call the callback on datasource event listeners
   */
  void onError(Event e) {
    listeners.where((l) => l is DataSourceConnectionEventListener).forEach((l) {
      l.onDataSourceError("");
    });
  }
}
