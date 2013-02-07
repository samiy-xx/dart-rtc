part of rtc_client;

class StreamingSignalHandler extends ChannelSignalHandler {
  String other = null;
  
  StreamingSignalHandler(DataSource ds) : super(ds) {
    registerHandler(PacketType.JOIN, onJoinChannel);
    registerHandler(PacketType.ID, onIdExistingChannelUser);
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
  
  void sendMessage(String id, String message) {
    send(PacketFactory.get(new UserMessage.With(other, message)));
  }
  
  @Override
  void handleJoin(JoinPacket join) {
    super.handleJoin(join);
    PeerWrapper pw = peerManager.findWrapper(join.id);
    MediaStream ms = peerManager.getLocalStream();
    if (ms != null)
      pw.addStream(ms);
  }
  
  @Override
  void handleId(IdPacket id) {
    super.handleId(id);
    if (!id.id.isEmpty) {
      PeerWrapper pw = peerManager.findWrapper(id.id);
      MediaStream ms = peerManager.getLocalStream();
      if (ms != null)
        pw.addStream(ms);
    }
  }
}

