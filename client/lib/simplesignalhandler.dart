part of rtc_client;

class SimpleSignalHandler extends SignalHandler {
  
  SimpleSignalHandler(VideoManager vm) : super(vm){
    registerHandler("id", handleId);
    registerHandler("join", handleJoin);
  }
  
  void handleJoin(JoinPacket packet) {
    _log.Debug("JoinPacket room ${packet.roomId} user ${packet.userId}");
    PeerWrapper p = createPeerWrapper();
    p.room = packet.roomId;
    p.id = packet.userId;
    p._isHost = true;
    p.addStream(_videoManager.getLocalStream());
  }
  
  void handleId(IdPacket id) {
    _log.Debug("ID packet: room ${id.roomId} user ${id.userId}");
    PeerWrapper p = createPeerWrapper();
    p.id = id.userId;
    p.room = id.roomId;
  }
}
