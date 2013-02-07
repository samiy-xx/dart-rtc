part of rtc_server;

class WheelServer extends WebSocketServer {
  /**
   * Constructor
   * Register all handlers here
   */
  WheelServer() {
    registerHandler(PacketType.HELO, handleIncomingHelo);
    registerHandler(PacketType.BYE, handleIncomingBye);
    registerHandler(PacketType.RANDOM, handleRandomUserRequest);
    registerHandler(PacketType.USERMESSAGE, handleUserMessage);
    registerHandler(PacketType.DISCONNECTED, handleDisconnect);
  }
  
  /**
   * Handle Helo packet
   */
  void handleIncomingHelo(HeloPacket p, WebSocketConnection c) {
    User u = _container.createUser(c);
    sendPacket(c, new ConnectionSuccessPacket.With(u.id));
  }
  
  /**
   * Handle Bye packet
   */
  void handleIncomingBye(ByePacket p, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    if (user.isTalking) {
      for (int i = 0; i < user.talkers.length; i++) {
        User talker = user.talkers[i];
        sendPacket(talker.connection, new ByePacket.With(user.id));
      }
    }
    _container.removeUser(user);
    user.terminate();
  }
  
  void handleDisconnect(Disconnected dc, WebSocketConnection c) {
    try {
      User user = _container.findUserByConn(c);
      if (user.isTalking) {
        for (int i = 0; i < user.talkers.length; i++) {
          User other = user.talkers[i];
          sendPacket(other.connection, new Disconnected.With(user.id));
          other.talkers.clear();
        }
        user.talkers.clear();
      }
    } catch (e) {
      print("handleDisconnect: Fucked up: $e");
    }
  }
  /**
   * Handle random user request packet
   */
  void handleRandomUserRequest(RandomUserPacket p, WebSocketConnection c) {
    try {
      User user = _container.findUserByConn(c);
      
      if (user.isTalking) {
        for (int i = 0; i < user.talkers.length; i++) {
          User other = user.talkers[i];
          sendPacket(other.connection, new Disconnected.With(user.id));
          other.talkers.clear();
        }
        user.talkers.clear();
      }
      
      User rnd = _container.findRandomUser(user);
      if (rnd != null) {
        // TODO: Fix. use user id as first parameter on both packets
        sendPacket(user.connection, new JoinPacket.With("", rnd.id));
        sendPacket(rnd.connection, new IdPacket.With(user.id, ""));
      } else {
        sendPacket(user.connection, new IdPacket.With("", ""));
      }
    } catch(e) {
      print("Fucked up: $e");
    }
  }
  
  void handleUserMessage(UserMessage um, WebSocketConnection c) {
    try {
      if (um.id == null || um.id.isEmpty) {
        print ("id was null or empty");
        return;
      }
      User user = _container.findUserByConn(c);
      User other = _container.findUserById(um.id);
      
      if (user == null || other == null) {
        print("user wass not found");
        return;
      }
      
      um.id = user.id;
      
      sendPacket(other.connection, um);
      
    } on NoSuchMethodError catch(e) {
      print("Somethign was null: $e");
    } catch(e) {
      print(e);
    }
  }
}
