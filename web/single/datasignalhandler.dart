part of demo_client;

class DataSignalHandler extends ChannelSignalHandler{
String other = null;
  
  DataSignalHandler(DataSource ds) : super(ds) {
    registerHandler("connected", onConnect);
    registerHandler("join", onJoinChannel);
    registerHandler("id", onIdExistingChannelUser);
    registerHandler("usermessage", onUserMessage);
  }
  
  void onJoinChannel(JoinPacket p) {
    if (channelId != "")
      print("got channel id channelId");
    
    if (p.id != id)
      other = p.id;
  }
  
  void onIdExistingChannelUser(IdPacket p) {
    if (p.id != id)
      other = p.id;
  }
  
  void onConnect(ConnectionSuccessPacket p) {
    print("Connected, my id is ${p.id}");
  }
  
  void sendMessage(String id, String message) {
    send(PacketFactory.get(new UserMessage.With(other, message)));
  }
  
  void onUserMessage(UserMessage m) {
    print("user message");
  }
  
  void handleJoin(JoinPacket join) {
    super.handleJoin(join);
    /*PeerWrapper pw = peerManager.findWrapper(join.id);
    MediaStream ms = peerManager.getLocalStream();
    pw.addStream(ms);*/
    PeerWrapper pw = peerManager.findWrapper(join.id);
    //pw.initialize();
  }
  
  void handleId(IdPacket id) {
    super.handleId(id);
    
    /*if (!id.id.isEmpty) {
      PeerWrapper pw = peerManager.findWrapper(id.id);
      MediaStream ms = peerManager.getLocalStream();
      pw.addStream(ms);
    }*/
    PeerWrapper pw = peerManager.findWrapper(id.id);
    //pw.initialize();
  }
}
