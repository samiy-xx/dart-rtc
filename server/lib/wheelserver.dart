part of rtc_server;

class WheelServer extends Server {
  /**
   * Constructor
   * Register all handlers here
   */
  WheelServer() {
    registerHandler("helo", handleIncomingHelo);
    registerHandler("bye", handleIncomingBye);
    registerHandler("random", handleRandomUserRequest);
  }
  
  void handleIncomingHelo(HeloPacket p, WebSocketConnection c) {
    User u = _container.createUser(c);
    sendToClient(c, JSON.stringify(new AckPacket.With(u.id, "")));
  }
  
  void handleIncomingBye(HeloPacket p, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    if (user.isTalking) {
      for (int i = 0; i < user.talkers.length; i++) {
        User talker = user.talkers[i];
        sendToClient(talker.connection, JSON.stringify(new ByePacket.With(user.id, "")));
      }
    }
    _container.removeUser(user);
    user.terminate();
  }
  
  void handleRandomUserRequest(RandomUserPacket p, WebSocketConnection c) {
    
  }
}
