part of rtc_server;

/**
 * ---------------------------------------------------
 * Copyright(c) 2012 Sami Ylönen sami.ylonen@gmail.com
 * ---------------------------------------------------
 * Ad-hoc WebSocketServer responsible for relaying packets between clients
 * and keeping track of rooms
 */
class RoomServer extends Server {
  
  RoomServer() : super() {
    registerHandler("helo", handleIncomingHelo);
    registerHandler("bye", handleIncomingBye);
    registerHandler("pong", handleIncomingPong);
    registerHandler("description", handleIncomingDescription);
    registerHandler("ice", handleIncomingIce);
    registerHandler("connected", handleIncomingConnected);
  }
  
  /**
   * handleIncomingHelo
   * Handles Helo packet, creates user and assigns to room
   */
  void handleIncomingHelo(HeloPacket helo, WebSocketConnection c) {
    try {
      // Create the user
      RoomUser u;
      if (helo.userId != null && !helo.userId.isEmpty)
        u = _container.createUserFromId(helo.userId, c);
      else
        u = _container.createUser(c);
      
      print("Created new user with id ${u.id}");
      
      
      if (helo.roomId == null || helo.roomId.isEmpty) {
        c.close(1003, "Specify room id");
      }
      
      Room r = _container.findRoom(helo.roomId);
      if (r != null && r.canJoin) {
        logger.Debug("room found, joining.");
        //c.send(JSON.stringify(new AckPacket.With(u.id, r.id)));
        sendToClient(c, JSON.stringify(new AckPacket.With(u.id, r.id)));
        //u.room = r;
        r.join(u);
      } else {
        logger.Debug("Attempting to create room with id ${helo.roomId}");
        r = _container.createRoomWithId(helo.roomId, 5);
        if (r != null && r.canJoin) {
          logger.Debug("room created joining with");
          //c.send(JSON.stringify(new AckPacket.With(u.id, r.id)));
          sendToClient(c, JSON.stringify(new AckPacket.With(u.id, r.id)));
          //u.room = r;
          r.join(u);
        }
      };
    } on Exception catch(e, trace) {
      logger.Error("Exception: $e");
    } catch (e, trace) {
      logger.Error("Last catch $e");
    }
  }
  
  void handleIncomingBye(ByePacket p, c) {
    RoomUser sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    logger.Debug("Notifying users, user leaving");
    sender.room.sendToAllExceptSender(sender, JSON.stringify(new ByePacket.With(sender.id, sender.room.id)));
    _container.removeUser(sender);
    logger.Debug("User left");
    sender.terminate();
    logger.Debug("User terminated");
  }
  
  void handleIncomingPong(PongPacket p, c) {
    logger.Debug("HAndling pong");
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
  }
  
  void handleIncomingDescription(DescriptionPacket desc, WebSocketConnection c) {
    
    RoomUser sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    RoomUser receiver = _container.findUserById(desc.userId);
    receiver.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    if (sender == null || receiver == null) {
      logger.Warning("Sender or Receiver not found");
      return;
    }
    
    if (sender == receiver) {
      logger.Warning("Sending to self, abort");
      return;
    }
    
    // Dont need this? incase we want to route?
    /*if (sender.room != receiver.room) {
      logger.Warning("Not in same room, aborting");
      return;
    }*/
    
    logger.Debug("Desc from ${sender.id} to ${receiver.id}");
    receiver.send(JSON.stringify(new DescriptionPacket.With(desc.sdp, desc.type, sender.id, sender.room.id)));

  }
  
  void handleIncomingIce(ICEPacket ice, WebSocketConnection c) {
    RoomUser sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    RoomUser receiver = _container.findUserById(ice.userId);
    receiver.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    if (sender == null || receiver == null) {
      logger.Warning("Sender or Receiver not found");
      return;
    }
    
    if (sender == receiver) {
      logger.Warning("Sending to self, abort");
      return;
    }
    
    // Dont need this? incase we want to route?
    /*if (sender.room != receiver.room) {
      logger.Warning("Not in same room, aborting");
      return;
    }*/
    
    logger.Debug("Ice from ${sender.id} to ${receiver.id}");
    receiver.send(JSON.stringify(new ICEPacket.With(ice.candidate, ice.sdpMid, ice.sdpMLineIndex, sender.id, sender.room.id)));
  }
  
  void handleIncomingConnected(ConnectedPacket p, WebSocketConnection c) {
    RoomUser sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    RoomUser receiver = _container.findUserById(p.target);
    receiver.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    sender.talkTo(receiver);
  }
  /*
  void handleIncomingRouteRequest(RoutePacket p, WebSocketConnection c) {
    RoomUser sender = _container.findUserByConn(c);
    RoomUser target = _container.findUserById(p.target);
    
    RoomUser router = _container.findRouter(sender, target);
    
    if (router != null) {
      sendToClient(sender.connection, JSON.stringify(new RoutePacket.With(sender.id, target.id, router.id)));
    }
  }*/
}