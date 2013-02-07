part of rtc_client;

class WheelSignalHandler extends SignalHandler {
  String other = null;
  VideoElement _aux;
  Function _test;
  
  WheelSignalHandler(DataSource ds) : super(ds) {
    registerHandler(PacketType.CONNECTED, onConnect);
    registerHandler(PacketType.DISCONNECTED, onUserDisconnect);
    registerHandler(PacketType.ID, onIdExistingChannelUser);
    registerHandler(PacketType.USERMESSAGE, onUserMessage);
  }
  
  void onIdExistingChannelUser(IdPacket p) {
    if (p.id != id)
      other = p.id;
  }
  
  void onConnect(ConnectionSuccessPacket p) {
    print("Connected, my id is ${p.id}");
  }
  
  void onUserDisconnect(Disconnected d) {
    PeerWrapper peer = getPeerManager().findWrapper(d.id);
    if (peer != null) {
      peer.close();
      getPeerManager().remove(peer);
    }
  }

  void onUserMessage(UserMessage m) {
    print("user message");
  }
  
  void requestRandomUser() {
    send(PacketFactory.get(new RandomUserPacket.With(id)));
  }
  
  void sendMessage(String id, String message) {
    send(PacketFactory.get(new UserMessage.With(other, message)));
  }
  
  void handleJoin(JoinPacket join) {
    super.handleJoin(join);
    
    PeerWrapper pw = peerManager.findWrapper(join.id);
    MediaStream ms = peerManager.getLocalStream();
    pw.addStream(ms);
    
  }
  
  void handleId(IdPacket id) {
    super.handleId(id);
    
    if (!id.id.isEmpty) {
      PeerWrapper pw = peerManager.findWrapper(id.id);
      MediaStream ms = peerManager.getLocalStream();
      pw.addStream(ms);
    }
  }
  
  
}
