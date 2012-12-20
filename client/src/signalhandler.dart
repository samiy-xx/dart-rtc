part of rtc_client;

/**
 * SignalHandler
 */
class SignalHandler {
  /* Web socket status codes */
  //TODO: These are not all correct
  static final int CLOSE_NORMAL = 1000; 
  static final int CLOSE_GOING_AWAY = 1001; 
  static final int CLOSE_PROTOCOL_ERROR = 1002; 
  static final int CLOSE_UNSUPPORTED = 1003;
  static final int RESERVED = 1004;
  static final int NO_STATUS = 1005;
  static final int ABNORMAL_CLOSE = 1006;
  static final int DATA_NOT_CONSISTENT = 1007;
  static final int POLICY_VIOLATION = 1008;
  static final int MESSAGE_TOO_LARGE = 1009;
  static final int NEGOTIATIONS_FAILED = 1010;
  static final int UNEXPECTED_CONDITION = 1011;
  static final int HANDSHAKE_FAILURE = 1015;
  
  Logger _log = new Logger();
  
  /* Web socket connection */
  WebSocket _ws;
  
  /* Peer manager */
  PeerManager _peerManager;
  
  /* Video manager */
  VideoManager _videoManager;
  
  /** Getter for PeerManager */
  PeerManager get peerManager => getPeerManager();
  
  /** Setter for PeerMAnager*/
  set peerManager(PeerManager p) => setPeerManager(p);
  
  String _id;
  String _channelId;
  
  set channelId(String value) => _channelId = value;
  
  String get id => _id;
  String get channelId => _channelId;
  
  Map<String, List<Function>> _methodHandlers;
  
  /**
   * Constructor
   */
  SignalHandler(VideoManager vm) {
    _videoManager = vm;
    _peerManager = new PeerManager(this, vm);
    _methodHandlers = new Map<String, List<Function>>();
    
    registerHandler("ping", handlePing);
    registerHandler("ice", handleIce);
    registerHandler("desc", handleDescription);
    registerHandler("bye", handleBye);
    registerHandler("connected", handleConnectionSuccess);
    registerHandler("join", handleJoin);
    registerHandler("id", handleId);
  }
  
  void registerHandler(String type, Function handler) {
    if (!_methodHandlers.containsKey(type))
      _methodHandlers[type] = new List<Function>();
    _methodHandlers[type].add(handler);
  }
  
  List<Function> getHandlers(String type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return null;
  }
  
  void initialize([String host]) {
    if (_peerManager == null)
      throw new Exception("PeerManager is null");
    
    if (_channelId == null)
      throw new Exception("channelId is null");
    
    _ws = new WebSocket(?host ? host :WEBSOCKET_SERVER);
    _ws.on.open.add(_onOpen);  
    _ws.on.close.add(_onClose);  
    _ws.on.error.add(_onError);  
    _ws.on.message.add(_onMessage);
  }
  
  void setPeerManager(PeerManager p) {
    if (p == null)
      throw new Exception("PeerManager is null");
    
    _peerManager = p;
  }
  
  PeerManager getPeerManager() {
    return _peerManager;
  }
  
  PeerWrapper createPeerWrapper() {
    return _peerManager.createPeer();
  }
  
  void _onOpen(Event e) {
    _log.Debug("WebSocket connection opened, sending HELO, ${_ws.readyState}");
    _ws.send(JSON.stringify(new HeloPacket.With(_channelId, "")));
  }
  
  void _onClose(CloseEvent e) {
    _log.Debug("Connection closed ${e.code.toString()} ${e.reason}");
  }
  
  void _onError(Event e) {
    _log.Error("Error $e");
  }
  
  void _onMessage(MessageEvent e) {
      Packet p = PacketFactory.getPacketFromString(e.data);
      if (p.packetType == null || p.packetType.isEmpty)
        return;
      
      List<Function> handlers = getHandlers(p.packetType);
      if (handlers != null) {
        for (Function f in handlers)
          f(p);
      } else {
        _log.Warning("Packet ${p.packetType} arrived but no handler set");
      }
        
      //Function f = getHandler(p.packetType);
      //if (f != null) {
      //  f(p);
      //} else {
      //  _log.Warning("Packet ${p.packetType} arrived but no handler set");
      //}
  }
  
  void send(String p) {
    _ws.send(p);
  }
  
  
  void handleJoin(JoinPacket packet) {
    if (packet.id == _id)
      _channelId = packet.channelId;
    
    _log.Debug("JoinPacket channel ${packet.channelId} user ${packet.id}");
    PeerWrapper p = createPeerWrapper();
    p.channel = packet.channelId;
    p.id = packet.id;
    p._isHost = true;
    p.addStream(_videoManager.getLocalStream());
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: channel ${id.channelId} user ${id.id}");
    PeerWrapper p = createPeerWrapper();
    p.id = id.id;
    p.channel = id.channelId;
  }
  void handleConnectionSuccess(ConnectionSuccessPacket p) {
    _log.Debug("Connection successfull user ${p.id}");
    _id = p.id;
  }
  
  void handleIce(ICEPacket p) {
    RtcIceCandidate candidate = new RtcIceCandidate({
      'candidate': p.candidate,
      'sdpMid': p.sdpMid,
      'sdpMLineIndex': p.sdpMLineIndex
    });
    
    PeerWrapper peer = _peerManager.findWrapper(p.userId);
    //Peer peer = findPeer(p.roomId, p.userId);
    if (peer != null) {
      peer.addRemoteIceCandidate(candidate);
    }
  }
  
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
    }
  }
  
  void handlePing(PingPacket p) {
    _log.Debug("Received PING, answering with PONG");
    _ws.send(JSON.stringify(new PongPacket()));
  }
  
  void handleBye(ByePacket p) {
    //_vm.removeVideoContainerById(p.userId);
    PeerWrapper peer = _peerManager.findWrapper(p.id);
    //Peer peer = findPeer(p.roomId, p.userId);
    if (peer != null) {
      peer.close();
    }
  }
  
  void close() {
    print ("readystate ${_ws.readyState}");
    if (_ws.readyState != WebSocket.CLOSED) {
      _ws.send(JSON.stringify(new ByePacket.With(_id)));
      
      _log.Debug("Closing socket");
      _ws.close(1000, "window unload");
    }
    
  }
}
