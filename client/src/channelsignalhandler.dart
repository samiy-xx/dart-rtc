part of rtc_client;

class ChannelSignalHandler extends SignalHandler{
  /* id for the channel */
  String _channelId;
  
  String get channelId => _channelId;
  set channelId(String value) => _channelId = value;
  
  ChannelSignalHandler() : super() {
    
  }
  
  void initialize([String host]) {
    if (_channelId == null)
      throw new Exception("channelId is null");
    
    super.initialize(host);
  }
  
  /**
   * Callback for websocket onopen
   */
  void onOpen(Event e) {
    _log.Debug("WebSocket connection opened, sending HELO, ${_ws.readyState}");
    _ws.send(PacketFactory.get(new HeloPacket.With(_channelId, "")));
  }
  
  void handleJoin(JoinPacket packet) {
    if (packet.id == _id)
      _channelId = packet.channelId;
    
    _log.Debug("JoinPacket channel ${packet.channelId} user ${packet.id}");
    PeerWrapper p = createPeerWrapper();
    p.channel = packet.channelId;
    p.id = packet.id;
    p._isHost = true;
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: channel ${id.channelId} user ${id.id}");
    if (id.id != null && !id.id.isEmpty) {
      PeerWrapper p = createPeerWrapper();
      p.id = id.id;
      p.channel = id.channelId;
    }
  }
}
