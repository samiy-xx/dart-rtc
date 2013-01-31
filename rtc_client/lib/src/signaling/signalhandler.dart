part of rtc_client;

/**
 * SignalHandler
 */
class SignalHandler extends PacketHandler implements PeerPacketEventListener, DataSourceConnectionEventListener {
  Logger _log = new Logger();
  
  /* Datasource */
  DataSource _dataSource;
  
  /* Peer manager */
  PeerManager _peerManager;
  
  /* Id for the local user */
  String _id;
  
  /* Enable datachannels */
  bool _dataChannelsEnabled = false;
  
  /** Getter for PeerManager */
  PeerManager get peerManager => getPeerManager();
  
  /** Getter for data source */
  DataSource get dataSource => _dataSource;
  
  /** Setter for PeerManager*/
  set peerManager(PeerManager p) => setPeerManager(p);
  
  /** Enable datachannels */
  set dataChannelsEnabled(bool value) => setDataChannelsEnabled(value);
  
  /** Id of the user */
  String get id => _id;
  
  // TODO: Should really figure out howto use GenericEventTarget here
  Map<String, List> _listeners;
  
  /**
   * Constructor
   */
  SignalHandler(DataSource ds) : super() {
    /* Init the datasource */
    _dataSource = ds;
    
    /* Subscribe to datasource events */
    _dataSource.subscribe(this);
    
    /* Init peer manager */
    _peerManager = new PeerManager();
    
    /* Subscribe to peer manager events */
    _peerManager.subscribe(this);
    
    // TODO: Should really figure out howto use GenericEventTarget here
    _listeners = new Map<String, List>();
    
    /* listen to ping, and respond with pong */
    registerHandler("ping", handlePing);
    
    /* Listen for ice, required to create the peer connection */
    registerHandler("ice", handleIce);
    
    /* Listen for sdp packets */
    registerHandler("desc", handleDescription);
    
    /* Listen for bye packets, when other user closes browser etc */
    registerHandler("bye", handleBye);
    
    /* Connect success to server */
    registerHandler("connected", handleConnectionSuccess);
    
    /* Listen for join, when someone joins same channel as you are */
    registerHandler("join", handleJoin);
    
    /* Listen for id, all users in channel you joined */
    registerHandler("id", handleId);
  }
  
  // TODO: Should really figure out howto use GenericEventTarget here
  void subscribe(String type, Object listener) {
    if (!_listeners.containsKey(type))
      _listeners[type] = new List<Object>();
    
    _listeners[type].add(listener);
  }
  
  /**
   * Sets data channels enabled
   * calls the same method in peer manager
   */
  void setDataChannelsEnabled(bool value) {
    _dataChannelsEnabled = value;
    _peerManager.dataChannelsEnabled = value;
  }
  
  /**
   * Initializes the connection to the web socket server
   * If no host parameter is given, uses the default one from lib
   * @param optional parameter host
   */
  void initialize([String host]) {
    if (_peerManager == null)
      throw new Exception("PeerManager is null");
    
    _dataSource.init();
  }
  
  /**
   * Sets the PeerManager
   */
  void setPeerManager(PeerManager p) {
    if (p == null)
      throw new Exception("PeerManager is null");
    
    _peerManager = p;
  }
  //TODO : Remove? Peermanager is singleton instance
  /**
   * Returns the peer manager
   * @return PeerManager
   */
  PeerManager getPeerManager() {
    return _peerManager;
  }
  
  /**
   * Creates a peer wrapper instance
   * @return PeerWrapper
   */
  PeerWrapper createPeerWrapper() {
    return _peerManager.createPeer();
  }
  
  /**
   * Implements DataSourceConnectionEventListener onOpen
   */
  void onOpenDataSource(String m) {
    _log.Debug("Connection opened, sending HELO, ${_dataSource.readyState}");
    _dataSource.send(PacketFactory.get(new HeloPacket.With("", "")));
  }
  
  /**
   * Implements DataSourceConnectionEventListener onClose
   */
  void onCloseDataSource(String m) {
    _log.Debug("Connection closed ${m}");
  }
  
  /**
   * Implements DataSourceConnectionEventListener onError
   */
  void onDataSourceError(String e) {
    _log.Error("Error $e");
  }
  
  /**
   * Implements DataSourceConnectionEventListener onMessage
   */
  void onDataSourceMessage(String m) {
    // Get the packet via PacketFactory
    try {
      Packet p = PacketFactory.getPacketFromString(m);
      if (p.packetType == null || p.packetType.isEmpty)
        return;
      
      if (!executeHandler(p)) 
        _log.Warning("Packet ${p.packetType} has no handlers set");
      
    } on Exception catch(e) {
      _log.Error(e.toString());
    }
  }
  
  /**
   * Send data trough datasource
   */
  void send(String p) {
    _dataSource.send(p);
  }
  
  /**
   * Implements PeerPacketEventListener onPacketToSend
   */
  void onPacketToSend(String p) {
    send(p);
  }
  
  /**
   * Handle join packet
   */
  void handleJoin(JoinPacket packet) {
    try {
      _log.Debug("(signalhandler.dart) JoinPacket channel ${packet.channelId} user ${packet.id}");
      PeerWrapper p = createPeerWrapper();
      p.id = packet.id;
      p.setAsHost(true);
    } catch (e) {
      _log.Error("(signalhandler.dart) Error handleJoin $e");
    }
    
    /*MediaStream ms = _videoManager.getLocalStream();
    if (ms != null)
      p.addStream(ms);*/
  }
  
  /**
   * Handle id packet
   */
  void handleId(IdPacket id) {
    _log.Debug("(signalhandler.dart) ID packet: channel ${id.channelId} user ${id.id}");
    if (id.id != null && !id.id.isEmpty) {
      PeerWrapper p = createPeerWrapper();
      p.id = id.id;
    }
  }
  
  /**
   * handle connection success
   */
  void handleConnectionSuccess(ConnectionSuccessPacket p) {
    _log.Debug("(signalhandler.dart) Connection successfull user ${p.id}");
    _id = p.id;
  }
  
  /**
   * Handles ice
   */
  void handleIce(IcePacket p) {
    RtcIceCandidate candidate = new RtcIceCandidate({
      'candidate': p.candidate,
      'sdpMid': p.sdpMid,
      'sdpMLineIndex': p.sdpMLineIndex
    });
    
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    if (peer != null) {
      peer.addRemoteIceCandidate(candidate);
    }
  }
  
  /**
   * Handles sdp description
   */
  void handleDescription(DescriptionPacket p) {
    _log.Debug("(signalhandler.dart) RECV: DescriptionPacket channel ${p.channelId} user ${p.id}");
   
    RtcSessionDescription t = new RtcSessionDescription({
      'sdp':p.sdp,
      'type':p.type
    });
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    //Peer p = findPeer(packet.roomId, packet.userId);
   
    if (peer != null) {
      _log.Debug("(signalhandler.dart) Setting remote description to peer");
      peer.setRemoteSessionDescription(t);
    } else {
      _log.Debug("(signalhandler.dart) Peer not found with id ${p.id}");
    }
  }
  
  /**
   * Handles ping from server, responds with pong
   */
  void handlePing(PingPacket p) {
    _log.Debug("(signalhandler.dart) Received PING, answering with PONG");
    _dataSource.send(PacketFactory.get(new PongPacket()));
  }
  
  /**
   * Handles Bye packet
   */
  void handleBye(ByePacket p) {
    _log.Debug("(signalhandler.dart) Received BYE from ${p.id}");
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    if (peer != null) {
      _log.Debug("(signalhandler.dart) Closing peer ${peer.id}");
      peer.close();
    }
  }
  
  /**
   * Close the Web socket connection to the signaling server
   */
  void close() {
    //if (_ws == null)
    //  return;
    
    //if (_ws.readyState != WebSocket.CLOSED) {
      _dataSource.send(PacketFactory.get(new ByePacket.With(_id)));
      _dataSource.close();
    //}
  }
}
