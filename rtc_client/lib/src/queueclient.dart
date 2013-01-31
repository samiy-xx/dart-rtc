part of rtc_client;

class QueueClient implements DataSourceConnectionEventListener, PeerConnectionEventListener, PeerMediaEventListener, SignalingConnectionEventListener {
  SignalHandler _sh;
  PeerManager _pm;
  DataSource _ds;
  
  
  QueueClient(DataSource ds) {
    _ds = ds;
    _pm = new PeerManager();
    _sh = new StreamingSignalHandler(ds);
  }
  
  /**
   * Implements SignalingConnectionEventListener
   */
  void onOpen() {
    
  }
  
  /**
   * Implements SignalingConnectionEventListener
   */
  void onClose() {
    
  }
  
  /**
   * Implements SignalingConnectionEventListener
   */
  void onError() {
    
  }
}



