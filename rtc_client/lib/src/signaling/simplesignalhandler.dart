part of rtc_client;

class SimpleSignalHandler extends SignalHandler {
  
  SimpleSignalHandler(DataSource ds) : super(ds){
    registerHandler(PacketType.ID, handleId);
    registerHandler(PacketType.JOIN, handleJoin);
  }
  
  void handleJoin(JoinPacket packet) {
    _log.Debug("JoinPacket room ${packet.channelId} user ${packet.id}");
    PeerWrapper p = createPeerWrapper();
    p.channel = packet.channelId;
    p.id = packet.id;
    p._isHost = true;
    //p.addStream(_videoManager.getLocalStream());
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: room ${id.channelId} user ${id.id}");
    PeerWrapper p = createPeerWrapper();
    p.id = id.id;
    p.channel = id.channelId;
  }
}
