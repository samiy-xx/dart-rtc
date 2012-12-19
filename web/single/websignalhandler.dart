part of single_client;

class WebSignalHandler extends SignalHandler {
  String other = null;
  
  WebSignalHandler(VideoManager vm) : super(vm) {
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
}

