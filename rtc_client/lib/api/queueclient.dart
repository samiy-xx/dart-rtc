part of rtc_client;

class QueueClient implements DataSourceConnectionEventListener, PeerConnectionEventListener, PeerMediaEventListener, SignalingConnectionEventListener {
  StreamingSignalHandler _sh;
  PeerManager _pm;
  DataSource _ds;
  
  bool _requireAudio = false;
  bool _requireVideo = false;
  bool _requireDataChannel = false;
  
  String _channel;
  String _myId;
  String _otherId;
  bool _isInQueue = false;
  
  List<QueueUser> _queued;
  List<QueueUser> get queued => _queued;
  
  bool get isChannelOwner => _sh.isChannelOwner;
  
  StreamController<MediaStreamAvailableEvent> _mediaStreamAvailableStreamController;
  Stream<MediaStreamAvailableEvent> get onRemoteMediaStreamAvailableEvent  => _mediaStreamAvailableStreamController.stream;
  
  StreamController<MediaStreamRemovedEvent> _mediaStreamRemovedStreamController;
  Stream<MediaStreamRemovedEvent> get onRemoteMediaStreamRemovedEvent  => _mediaStreamRemovedStreamController.stream;
  
  StreamController<InitializedEvent> _initializedController;
  Stream<InitializedEvent> get onInitializedEvent => _initializedController.stream;
  
  StreamController<SignalingOpenEvent> _signalingOpenController;
  Stream<SignalingOpenEvent> get onSignalingOpenEvent => _signalingOpenController.stream;
  
  StreamController<SignalingClosedEvent> _signalingCloseController;
  Stream<SignalingClosedEvent> get onSignalingCloseEvent => _signalingCloseController.stream;
  
  StreamController<SignalingErrorEvent> _signalingErrorController;
  Stream<SignalingErrorEvent> get onSignalingErrorEvent => _signalingErrorController.stream;
  
  StreamController<PeerStateChangedEvent> _peerStateChangeController;
  Stream<PeerStateChangedEvent> get onPeerStateChangeEvent => _peerStateChangeController.stream;
  
  StreamController<IceGatheringStateChangedEvent> _iceGatheringStateChangeController;
  Stream<IceGatheringStateChangedEvent> get onIceGatheringStateChangeEvent => _iceGatheringStateChangeController.stream;
  
  StreamController<DataSourceMessageEvent> _dataSourceMessageController;
  Stream<DataSourceMessageEvent> get onDataSourceMessageEvent => _dataSourceMessageController.stream;
  
  StreamController<DataSourceCloseEvent> _dataSourceCloseController;
  Stream<DataSourceCloseEvent> get onDataSourceCloseEvent => _dataSourceCloseController.stream;
  
  StreamController<DataSourceOpenEvent> _dataSourceOpenController;
  Stream<DataSourceOpenEvent> get onDataSourceOpenEvent => _dataSourceOpenController.stream;
  
  StreamController<DataSourceErrorEvent> _dataSourceErrorController;
  Stream<DataSourceErrorEvent> get onDataSourceErrorEvent => _dataSourceErrorController.stream;
  
  StreamController<PacketEvent> _packetController;
  Stream<PacketEvent> get onPacketEvent => _packetController.stream;
  
  StreamController<QueueEvent> _queueController;
  Stream<QueueEvent> get onQueueEvent => _queueController.stream;
  
  QueueClient(DataSource ds) {
    _ds = ds;
    _ds.subscribe(this);
    
    _pm = new PeerManager();
    _pm.subscribe(this);
    
    _sh = new StreamingSignalHandler(ds);
    
    
    
    _queued = new List<QueueUser>();
    
    _initializedController = new StreamController<InitializedEvent>.broadcast();
    _mediaStreamAvailableStreamController = new StreamController.broadcast();
    _mediaStreamRemovedStreamController = new StreamController.broadcast();
    _signalingOpenController = new StreamController.broadcast();
    _signalingCloseController = new StreamController.broadcast();
    _signalingErrorController = new StreamController.broadcast();
    _peerStateChangeController = new StreamController.broadcast();
    _iceGatheringStateChangeController = new StreamController.broadcast();
    _dataSourceMessageController = new StreamController.broadcast();
    _dataSourceCloseController = new StreamController.broadcast();
    _dataSourceOpenController = new StreamController.broadcast();
    _dataSourceErrorController = new StreamController.broadcast();
    _packetController = new StreamController.broadcast();
    _queueController = new StreamController.broadcast();
    
    _sh.registerHandler("queue", handleQueue);
    _sh.registerHandler("join", handleJoin);
    _sh.registerHandler("id", handleId);
    _sh.registerHandler("bye", handleBye);
    _sh.registerHandler("channel", handleChannelInfo);
  }
  
  void initialize() {
    if (_channel == null)
      throw new Exception("Channel can not be null, initialize with setChannel");
    
    if (!_requireAudio && !_requireVideo && !_requireDataChannel)
      throw new Exception("Must require either video, audio or data channel");
    
    if (MediaStream.supported) {
      window.navigator.getUserMedia(audio: _requireAudio, video: _requireVideo).then((LocalMediaStream stream) {
        _pm.setLocalStream(stream);
        _sh.initialize();
        _initializedController.add(new InitializedEvent(true, "UserMedia received"));
        _mediaStreamAvailableStreamController.add(new MediaStreamAvailableEvent(stream, null));
      });
    } else {
      _initializedController.add(new InitializedEvent(false, "Failed to get user media"));
    }
  }
  
  QueueClient setRequireAudio(bool b) {
    _requireAudio = b;
    return this;
  }
  
  QueueClient setRequireVideo(bool b) {
    _requireVideo = b;
    return this;
  }
  
  QueueClient setRequireDataChannel(bool b) {
    _requireDataChannel = b;
    _sh.setDataChannelsEnabled(b);
    return this;
  }
  
  QueueClient setChannel(String c) {
    _channel = c;
    _sh.channelId = c;
    return this;
  }
  
  void nextUser() {
    if (isChannelOwner) {
      disconnectUser();
    }
  }
  
  void disconnectUser() {
    
  }
  
  void handleChannelInfo(ChannelPacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void handleQueue(QueuePacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
    
    if (!_queueController.hasSubscribers)
      return;
    
    QueueUser qu = _findQueueUser(p.id);
    if (qu == null) {
      qu = new QueueUser(p.id, int.parse(p.position));
      _addToQueue(qu);
      _queueController.add(new QueueEvent(QueueEventType.ENTER, int.parse(p.position)));
      return;
    }
    qu.position = int.parse(p.position);
    
    //if (!isChannelOwner) {
      if (int.parse(p.position) == 0) {
        _queueController.add(new QueueEvent(QueueEventType.LEAVE, int.parse(p.position)));
        _removeFromQueue(qu);
      } else {
        _queueController.add(new QueueEvent(QueueEventType.MOVE, int.parse(p.position)));
        
      }  
    //}
    /*QueueUser qu = _findQueueUser(p.id);
    if (qu == null)
      _addToQueue(new QueueUser)
    if (isChannelOwner) {
      _queueController.add(new QueueEvent(QueueEventType.JOIN))
    } else {
      if (_isInQueue) {
        
      } else {
        
      }
    }*/
  }
  
  void handleJoin(JoinPacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void handleId(IdPacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void handleBye(ByePacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void _addToQueue(QueueUser u) {
    if (!_queued.contains(u))
      _queued.add(u);
  }
  
  void _removeFromQueue(QueueUser u) {
    int idx = _queued.indexOf(u);
    if (idx > -1)
      _queued.removeAt(idx);
  }
  
  QueueUser _findQueueUser(String id) {
    for (int i = 0; i < _queued.length; i++) {
      QueueUser u = _queued[i];
      if (u.id == id)
        return u;
    }
    
    return null;
  }
  /**
   * Remote media stream available from peer
   */
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool main) {
   if (_mediaStreamAvailableStreamController.hasSubscribers)
     _mediaStreamAvailableStreamController.add(new MediaStreamAvailableEvent(ms, pw));
  }
  
  /**
   * Media stream was removed
   */
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    if (_mediaStreamRemovedStreamController.hasSubscribers)
      _mediaStreamRemovedStreamController.add(new MediaStreamRemovedEvent(pw));
  }
  /**
   * Notifies listeners that peer state has changed
   */
  void onPeerStateChanged(PeerWrapper pw, String state) {
    if (_peerStateChangeController.hasSubscribers)
      _peerStateChangeController.add(new PeerStateChangedEvent(pw, state));
  }
  
  /**
   * Notifies listeners about ice state changes
   */
  void onIceGatheringStateChanged(PeerWrapper pw, String state) {
    if (_iceGatheringStateChangeController.hasSubscribers)
      _iceGatheringStateChangeController.add(new IceGatheringStateChangedEvent(pw, state));
  }

  /**
   * Signaling has connected to server
   */
  void onOpenSignaling() {
    if (_signalingOpenController.hasSubscribers)
      _signalingOpenController.add(new SignalingOpenEvent());
  }
  
  /**
   * Connection to the server has been closed
   */
  void onCloseSignaling() {
    if (_signalingCloseController.hasSubscribers)
      _signalingCloseController.add(new SignalingClosedEvent());
  }
  
  /**
   * Error =)
   */
  void onSignalingError() {
    if (_signalingErrorController.hasSubscribers)
      _signalingErrorController.add(new SignalingErrorEvent());
  }
  /**
   * Implements SignalingConnectionEventListener
   */
  void onDataSourceMessage(String m) {
    if (_dataSourceMessageController.hasSubscribers)
      _dataSourceMessageController.add(new DataSourceMessageEvent(m));
  }
  
  /**
   * Datasource is closing
   */
  void onCloseDataSource(String m) {
    if (_dataSourceCloseController.hasSubscribers)
      _dataSourceCloseController.add(new DataSourceCloseEvent(m));
  }
  
  /**
   * Datasource connection opens
   */
  void onOpenDataSource(String m) {
    if (_dataSourceOpenController.hasSubscribers)
      _dataSourceOpenController.add(new DataSourceOpenEvent(m));
  }
  
  /**
   * Datasource error
   */
  void onDataSourceError(String e) {
    if (_dataSourceErrorController.hasSubscribers)
      _dataSourceErrorController.add(new DataSourceErrorEvent(e));
  }
}

class QueueUser implements Comparable {
  DateTime entered;
  String id;
  int position;
  
  QueueUser(String i, int p) {
    id = i;
    position = p;
    entered = new DateTime.now();
  }
  
  int compareTo(QueueUser o) {
    if (position < o.position)
      return -1;
    
    if (position == o.position)
      return 0;
    
    return 1;
  }
}

