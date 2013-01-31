part of rtc_client;

abstract class RtcEvent {
  
}

class InitializedEvent extends RtcEvent {
  bool initialized = true;
}

class MediaStreamEvent extends RtcEvent {
  MediaStream ms;
  
  MediaStreamEvent(MediaStream m) {
    ms = m;
  }
}

class QueueClient implements DataSourceConnectionEventListener, PeerConnectionEventListener, PeerMediaEventListener, SignalingConnectionEventListener {
  SignalHandler _sh;
  PeerManager _pm;
  DataSource _ds;
  
  StreamController<RtcEvent> _mediaEventStreamController;
  Stream get onRemoteMediaStreamAvailableEvent  => _mediaEventStreamController.stream;
  
  StreamController<InitializedEvent> _initializedController;
  Stream<InitializedEvent> get onInitializedEvent => _initializedController.stream;
  
  QueueClient(DataSource ds) {
    _ds = ds;
    _pm = new PeerManager();
    _sh = new StreamingSignalHandler(ds);
    
    _initializedController = new StreamController<InitializedEvent>.broadcast();
    _mediaEventStreamController = new StreamController.broadcast();
    
  }
  
  void initialize() {
    //_sh.initialize();
    _initializedController.add(new Ini);
  }
  
  /**
   * Remote media stream available from peer
   */
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool main) {
   if (_mediaEventStreamController.hasSubscribers)
    _mediaEventStreamController.add("test");
  }
  
  /**
   * Media stream was removed
   */
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    
  }
  /**
   * Notifies listeners that peer state has changed
   */
  void onPeerStateChanged(PeerWrapper pw, String state) {
    
  }
  
  /**
   * Notifies listeners about ice state changes
   */
  void onIceGatheringStateChanged(PeerWrapper pw, String state) {
    
  }

  /**
   * Signaling has connected to server
   */
  void onOpenSignaling() {
    
  }
  
  /**
   * Connection to the server has been closed
   */
  void onCloseSignaling() {
    
  }
  
  /**
   * Error =)
   */
  void onSignalingError() {
    
  }
  /**
   * Implements SignalingConnectionEventListener
   */
  void onDataSourceMessage(String m) {
    
  }
  
  /**
   * Datasource is closing
   */
  void onCloseDataSource(String m) {
    
  }
  
  /**
   * Datasource connection opens
   */
  void onOpenDataSource(String m) {
    
  }
  
  /**
   * Datasource error
   */
  void onDataSourceError(String e) {
    
  }
}



