part of rtc_server;

/**
 * ---------------------------------------------------
 * Copyright(c) 2012 Sami Ylönen sami.ylonen@gmail.com
 * ---------------------------------------------------
 * Ad-hoc WebSocketServer responsible for relaying packets between clients
 * and keeping track of rooms
 */
class Server {
  HttpServer _httpServer;
  WebSocketHandler _wsHandler;
  
  // Container keeps track of users and rooms
  Container _container;
  
  // Ip address socket is going to be bind
  String _ip = null;
  
  // path for websocket
  String _path = null;
  
  // path for commands from server
  String _commandPath = null;
  
  // port to bind to
  int _port = 8234;
  
  // 2 second session timeout
  int _sessionTimeout = 2;
  
  // 1 minute
  int _timerTickInterval = 60000;
  
  Logger logger = new Logger();
  
  Timer _timer;
  
  Server() {
    _httpServer = new HttpServer();
    _httpServer.sessionTimeout = _sessionTimeout;
    _wsHandler = new WebSocketHandler();
    _container = new Container(this);
    _timer = new Timer.repeating(_timerTickInterval, onTimerTick);
  }
  
  void stop() {
    logger.Info("Stopping server");
    _timer.cancel();
    _httpServer.close();
  }
  
  void listen([String ip="0.0.0.0", int port=8234, String path="/ws", String command="/command"]) {
    _ip = ip;
    _path = path;
    _port = port;
    _commandPath = command;
    
    _httpServer.addRequestHandler((req) => req.path == _path, handler);
    _httpServer.addRequestHandler((req) => req.path == _commandPath, commandHandler);
    
    _httpServer.onError = (err) {
      logger.Error(err);
    };
    run();
  }
  
  void commandHandler(HttpRequest request, HttpResponse response) {
    print(request.connectionInfo.remoteHost);
    print(request.method);
    print(request.path);
   
    request.inputStream.onData = () {
      print(request.contentLength);
      print(request.inputStream.available());
      print(new String.fromCharCodes(request.inputStream.read(6)));
      
    };
    response.statusCode = 200;
    response.outputStream.writeString("Hihihi");
    response.outputStream.close();
  }
  
  void handler(HttpRequest request, HttpResponse response) {
    
    print("Incoming connection from: ${request.connectionInfo.remoteHost}");
    _wsHandler.onRequest(request, response);
  
  }
  
  void run() {
    logger.Info("Starting server on ip $_ip and port $_port");
    
    _wsHandler.onOpen = (WebSocketConnection conn) {
      try {
      conn.onMessage = (message) {
        logger.Debug("Raw message $message");
        Packet p = PacketFactory.getPacketFromString(message);
        
        switch (p.packetType) {
          case "helo":
            logger.Debug("HELO Packet");
            User u = _container.findUserByConn(conn);
            
            // Dont allow multiple helos's from same connection.
            // could be spam.
            if (u != null) {
              conn.close(1003, "Already HELO'd");
              logger.Warning("User exists, disconnecting");
            }
            handleIncomingHelo(p, conn);
            logger.Info(displayStatus());
            break;
          case "bye":
            logger.Debug ("BYE Packet");
            handleIncomingBye(p, conn);
            logger.Info(displayStatus());
            break;
          case "desc":
            logger.Debug ("DESCRIPTION Packet");
            handleIncomingDescription(p, conn);
            break;
          case "ice":
            logger.Debug ("ICE Packet");
            handleIncomingIce(p, conn);
            break;
          case "pong":
            logger.Debug ("PONG Packet");
            handleIncomingPong(p, conn);
            break;
          case "connected":
            logger.Debug ("CONNECTED Packet");
            handleIncomingConnected(p, conn);
            break;
          case "route":
            logger.Debug ("ROUTE Packet");
            handleIncomingRouteRequest(p, conn);
            break;
          default:
            logger.Debug("UNKNOWN Packet");
            break;
        }
        
      };
      } on Exception catch(e) {
        logger.Error("Error onMessage: $e");
      } catch(e) {
        logger.Error("Last catch onMessage: $e");
      }
      
      
      conn.onClosed = (int status, String reason) {
        logger.Debug('closed with $status for $reason');
        logger.Info(displayStatus());
      };
      
      
    };
    
    _httpServer.listen(_ip, _port);
  }
  
  String displayStatus() {
    StringBuffer buffer = new StringBuffer();
    buffer.add("Users: ${_container.userCount} Rooms: ${_container.roomCount}");
    return buffer.toString();
  }
  void sendToClient(WebSocketConnection c, String p) {
    try {
      c.send(p);
    } catch(e) {
      logger.Debug("Socket Dead? removing connection");
      try {
        User u = _container.findUserByConn(c);
        if (u != null) {
          _container.removeUser(u);
          u.room = null;
          u = null;
        }
        c.close(1000, "Assuming dead");
      } catch (e) {
        logger.Debug("Last catch, sendToClient $e");
      }
    }
  }
  
  void onTimerTick(Timer t) {
    _container.cleanUp();
  }
  /**
   * handleIncomingHelo
   * Handles Helo packet, creates user and assigns to room
   */
  void handleIncomingHelo(HeloPacket helo, WebSocketConnection c) {
    try {
      // Create the user
      User u;
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
    User sender = _container.findUserByConn(c);
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
    
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    User receiver = _container.findUserById(desc.userId);
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
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    User receiver = _container.findUserById(ice.userId);
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
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    User receiver = _container.findUserById(p.target);
    receiver.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    sender.talkTo(receiver);
  }
  
  void handleIncomingRouteRequest(RoutePacket p, WebSocketConnection c) {
    User sender = _container.findUserByConn(c);
    User target = _container.findUserById(p.target);
    
    User router = _container.findRouter(sender, target);
    
    if (router != null) {
      sendToClient(sender.connection, JSON.stringify(new RoutePacket.With(sender.id, target.id, router.id)));
    }
  }
}