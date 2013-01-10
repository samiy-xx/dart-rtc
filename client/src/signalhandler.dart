part of rtc_client;

/**
 * SignalHandler
 */
class SignalHandler implements PeerPacketEventListener {
  Logger _log = new Logger();
  
  /* Web socket connection */
  WebSocket _ws;
  
  /* Peer manager */
  PeerManager _peerManager;
  
  /* Id for the local user */
  String _id;
  
  bool _dataChannelsEnabled = false;
  
  /* List containing all thje message method handlers */
  Map<String, List<Function>> _methodHandlers;
  
  /** Getter for PeerManager */
  PeerManager get peerManager => getPeerManager();
  
  /** Setter for PeerManager*/
  set peerManager(PeerManager p) => setPeerManager(p);
  
  
  set dataChannelsEnabled(bool value) => setDataChannelsEnabled(value);
  
  String get id => _id;
  
  
  Map<String, List> _listeners;
  /**
   * Constructor
   */
  SignalHandler() {
    
    _peerManager = new PeerManager();
    _peerManager.subscribe(this);
    _methodHandlers = new Map<String, List<Function>>();
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
    
    /* Listenfor join, when someone joins same channel as you are */
    registerHandler("join", handleJoin);
    
    /* Listen for id, all users in channel you joined */
    registerHandler("id", handleId);
  }
  
  void subscribe(String type, Object listener) {
    if (!_listeners.containsKey(type))
      _listeners[type] = new List<Object>();
    
    _listeners[type].add(listener);
  }
  
  void setDataChannelsEnabled(bool value) {
    _dataChannelsEnabled = value;
    _peerManager.dataChannelsEnabled = value;
  }
  
  /**
   * Registers a handler for specified message type
   * @param type the message type
   * @param handler the function handling this message
   */
  void registerHandler(String type, Function handler) {
    if (!_methodHandlers.containsKey(type))
      _methodHandlers[type] = new List<Function>();
    _methodHandlers[type].add(handler);
  }
  
  /**
   * Clears all handlers associated to "type"
   * @param type the message type
   */
  void clearHandlers(String type) {
    if (_methodHandlers.containsKey(type))
      _methodHandlers.remove(type);
  }
  
  /**
   * Returns a list of functions handling given message type
   * @param type the message type
   * @return List<Function> the message handler functions
   */
  List<Function> getHandlers(String type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return null;
  }
  
  /**
   * Initializes the connection to the web socket server
   * If no host parameter is given, uses the default one from lib
   * @param optional parameter host
   */
  void initialize([String host]) {
    if (_peerManager == null)
      throw new Exception("PeerManager is null");
    
    _ws = new WebSocket(?host ? host :WEBSOCKET_SERVER);
    _ws.on.open.add(onOpen);  
    _ws.on.close.add(onClose);  
    _ws.on.error.add(onError);  
    _ws.on.message.add(_onMessage);
  }
  
  //TODO : Remove?
  /**
   * Sets the PeerManager
   * @param p PeerManager
   */
  void setPeerManager(PeerManager p) {
    if (p == null)
      throw new Exception("PeerManager is null");
    
    _peerManager = p;
  }
  //TODO : Remove?
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
   * Callback for websocket onopen
   */
  void onOpen(Event e) {
    _log.Debug("WebSocket connection opened, sending HELO, ${_ws.readyState}");
    _ws.send(PacketFactory.get(new HeloPacket.With("", "")));
  }
  
  /**
   * Callback for websocket onclose
   */
  void onClose(CloseEvent e) {
    _log.Debug("Connection closed ${e.code.toString()} ${e.reason}");
  }
  
  /**
   * Callback for websocket onerror
   */
  void onError(Event e) {
    _log.Error("Error $e");
  }
  
  /*
   * Private callback for websocket onmessage
   */
  void _onMessage(MessageEvent e) {
    // Get the packet via PacketFactory
    Packet p = PacketFactory.getPacketFromString(e.data);
    if (p.packetType == null || p.packetType.isEmpty)
      return;
    
    // Get the handlers for this message
    List<Function> handlers = getHandlers(p.packetType);
    if (handlers != null) {
      for (Function f in handlers)
        f(p);
    } else {
      _log.Warning("Packet ${p.packetType} has no handlers set");
    }
  }
  
  void send(String p) {
    _ws.send(p);
  }
  
  void onPacketToSend(String p) {
    send(p);
  }
  
  void handleJoin(JoinPacket packet) {
    _log.Debug("JoinPacket channel ${packet.channelId} user ${packet.id}");
    PeerWrapper p = createPeerWrapper();
    p.id = packet.id;
    p._isHost = true;
    
    /*MediaStream ms = _videoManager.getLocalStream();
    if (ms != null)
      p.addStream(ms);*/
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: channel ${id.channelId} user ${id.id}");
    if (id.id != null && !id.id.isEmpty) {
      PeerWrapper p = createPeerWrapper();
      p.id = id.id;
    }
  }
  
  /**
   * handle connection success
   */
  void handleConnectionSuccess(ConnectionSuccessPacket p) {
    _log.Debug("Connection successfull user ${p.id}");
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
    _log.Debug("DescriptionPacket channel ${p.channelId} user ${p.id} sdp ${p.sdp}");
   
    RtcSessionDescription t = new RtcSessionDescription({
      'sdp':p.sdp,
      'type':p.type
    });
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    //Peer p = findPeer(packet.roomId, packet.userId);
   
    if (peer != null) {
      _log.Debug("Setting remote description to peer");
      peer.setRemoteSessionDescription(t);
    } else {
      _log.Debug("Peer not found with id ${p.id}");
    }
  }
  
  /**
   * Handles ping from server, responds with pong
   */
  void handlePing(PingPacket p) {
    _log.Debug("Received PING, answering with PONG");
    _ws.send(PacketFactory.get(new PongPacket()));
  }
  
  /**
   * Handles Bye packet
   */
  void handleBye(ByePacket p) {
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    if (peer != null) {
      peer.close();
    }
  }
  
  /**
   * Close the Web socket connection to the signaling server
   */
  void close() {
    if (_ws == null)
      return;
    
    if (_ws.readyState != WebSocket.CLOSED) {
      _ws.send(PacketFactory.get(new ByePacket.With(_id)));
      _ws.close(1000, "window unload");
    }
  }
}
