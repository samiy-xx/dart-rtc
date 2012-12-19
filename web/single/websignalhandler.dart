part of single_client;

class WebSignalHandler extends SignalHandler {
  WebSignalHandler(VideoManager vm) : super(vm) {
    registerHandler("connected", onConnect);
    //registerHandler("usermessage", onMessage);
  }
  
  
  void onConnect(ConnectionSuccessPacket p) {
    
  }
  
  
  
  void sendMessage(String id, [String roomId]) {
    
  }
}
