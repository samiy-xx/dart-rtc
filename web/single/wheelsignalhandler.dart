part of single_client;

class WheelSignalhandler extends SignalHandler {
  String other = null;
  
  WheelSignalhandler() : super() {
    registerHandler("connected", onConnect);
    registerHandler("disconnected", onUserDisconnect);
    
    registerHandler("id", onIdExistingChannelUser);
    registerHandler("usermessage", onUserMessage);
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
    }
  }
  
  void onUserMessage(UserMessage m) {
    print("user message");
  }
  
  void sendMessage(String id, String message) {
    send(PacketFactory.get(new UserMessage.With(other, message)));
  }
  
  
}
