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
    sendToClient(c, JSON.stringify(new ConnectionSuccessPacket.With(u.id)));
  }
  
  void handleIncomingBye(HeloPacket p, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    if (user.isTalking) {
      for (int i = 0; i < user.talkers.length; i++) {
        User talker = user.talkers[i];
        sendToClient(talker.connection, JSON.stringify(new ByePacket.With(user.id)));
      }
    }
    _container.removeUser(user);
    user.terminate();
  }
  
  void handleRandomUserRequest(RandomUserPacket p, WebSocketConnection c) {
    try {
      User user = _container.findUserByConn(c);
      
      if (user.isTalking) {
        for (int i = 0; i < user.talkers.length; i++) {
          User other = user.talkers[i];
          sendToClient(other.connection, PacketFactory.get(new Disconnected.With(user.id)));
        }
        user.talkers.clear();
      }
      
      User rnd = _container.findRandomUser(user);
      if (rnd != null) {
        // TODO: Fix. use user id as first parameter on both packets
        sendToClient(user.connection, PacketFactory.get(new JoinPacket.With("", rnd.id)));
        sendToClient(rnd.connection, PacketFactory.get(new IdPacket.With(user.id, "")));
      }
    } catch(e) {
      print("Fucked up: $e");
    }
  }
}
