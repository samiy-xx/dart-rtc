part of rtc_client;

/**
 * SignalHandler
 */
class SignalHandler {
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
  WebSocket _ws;
  PeerManager _peerManager;
  
  /** Getter for PeerManager */
  PeerManager get peerManager => getPeerManager();
  
  /** Setter for PeerMAnager*/
  set peerManager(PeerManager p) => setPeerManager(p);
  
  String _userId;
  String _roomId;
  /**
   * Constructor
   */
  SignalHandler() {
    _peerManager = new PeerManager(this);
  }
  
  SignalHandler.With(PeerManager p) {
    _peerManager = p;
  }
  
  void initialize() {
    if (_peerManager == null)
      throw new Exception("PeerManager is null");
    
    _ws = new WebSocket(WEBSOCKET_SERVER);
    _ws.on.open.add(onOpen);  
    _ws.on.close.add(onClose);  
    _ws.on.error.add(onError);  
    _ws.on.message.add(onMessage);
  }
  
  void setPeerManager(PeerManager p) {
    if (p == null)
      throw new Exception("PeerManager is null");
    
    _peerManager = p;
  }
  
  PeerManager getPeerManager() {
    return _peerManager;
  }
  
  void onOpen(Event e) {
    _log.Debug("WebSocket connection opened, sending HELO");
    _ws.send(JSON.stringify(new HeloPacket()));
  }
  
  void onClose(CloseEvent e) {
    _log.Debug("Connection closed ${e.code.toString()} ${e.reason}");
  }
  
  void onError(Event e) {

  }
  
  void onMessage(MessageEvent e) {
      Packet p = PacketFactory.getPacketFromString(e.data);
      if (p.packetType == null || p.packetType.isEmpty)
        return;
      
      switch (p.packetType) {
        case "join":
          handleJoin(p);
          break;
        case "ack":
          handleAck(p);
          break;
        case "ice":
          handleIce(p);
          break;
        case "desc":
          handleDescription(p);
          break;
        case "id":
          handleId(p);
          break;
        case "ping":
          handlePing(p);
          break;
        case "bye":
          handleBye(p);
          break;
        case "route":
          handleRouteReply(p);
          break;
        case "routeme":
          handleRoute(p);
          break;
        default:
          _log.Warning("Received unkown message $p");
          break;
      }
    
  }
  void send(Packet p) {
    _ws.send(p.toString());
  }
  
  void handleJoin(JoinPacket packet) {
    _log.Debug("JoinPacket room ${packet.roomId} user ${packet.userId}");
    PeerWrapper p = _peerManager.createPeer();
    p.room = packet.roomId;
    p.id = packet.userId;
    p._isHost = true;
    p.addLocalStream();
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: room ${id.roomId} user ${id.userId}");
    PeerWrapper p = _peerManager.createPeer();
    p.id = id.userId;
    p.room = id.roomId;
  }
  
  void handleAck(AckPacket ack) {
    _log.Debug("ACK Packet, assigning room ${ack.roomId} user ${ack.userId}");
    _roomId = ack.roomId;
    _userId = ack.userId;
  }
  
  void handleIce(ICEPacket p) {
    
  }
  void handleDescription(DescriptionPacket p) {
    
  }
  
  
  
  void handlePing(PingPacket p) {
    _log.Debug("Received PING, answering with PONG");
    send(new PongPacket());
  }
  void handleBye(ByePacket p) {
    
  }
  void handleRouteReply(RoutePacket p) {
    
  }
  void handleRoute(RoutePacket p) {
    
  }
}
