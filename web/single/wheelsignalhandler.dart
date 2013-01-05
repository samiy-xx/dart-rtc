part of single_client;

class WheelSignalHandler extends SignalHandler implements PeerMediaEventListener {
  String other = null;
  
  WheelSignalHandler() : super() {
    registerHandler("connected", onConnect);
    registerHandler("disconnected", onUserDisconnect);
    
    registerHandler("id", onIdExistingChannelUser);
    registerHandler("usermessage", onUserMessage);
    
    peerManager.subscribe(this);
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
  
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool ismain) {
    new Logger().Debug("WHEEL HANDLER RECEIVED");
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
    //pw.initialize();
  }
  
  void handleId(IdPacket id) {
    super.handleId(id);
    
    if (!id.id.isEmpty) {
      PeerWrapper pw = peerManager.findWrapper(id.id);
      MediaStream ms = peerManager.getLocalStream();
      pw.addStream(ms);
    }
    //pw.initialize();
  }
  
  
}
