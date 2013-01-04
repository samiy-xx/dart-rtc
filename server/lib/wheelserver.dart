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
    registerHandler("usermessage", handleUserMessage);
  }
  
  /**
   * Handle Helo packet
   */
  void handleIncomingHelo(HeloPacket p, WebSocketConnection c) {
    User u = _container.createUser(c);
    sendToClient(c, JSON.stringify(new ConnectionSuccessPacket.With(u.id)));
  }
  
  /**
   * Handle Bye packet
   */
  void handleIncomingBye(ByePacket p, WebSocketConnection c) {
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
  
  /**
   * Handle random user request packet
   */
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
      } else {
        sendToClient(user.connection, PacketFactory.get(new IdPacket.With("", "")));
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
      print("handling user message 2");
      sendToClient(other.connection, PacketFactory.get(um));
      print("handling user message 3");
    } on NoSuchMethodError catch(e) {
      print("Somethign was null: $e");
    } catch(e) {
      print(e);
    }
  }
}
