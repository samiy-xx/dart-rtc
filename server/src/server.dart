part of rtc_server;

class Server {
  /* The http server */
  HttpServer _httpServer;
  
  /* Websocket handler */
  WebSocketHandler _wsHandler;
  
  /* Container keeps track of users and rooms */
  UserContainer _container;
  
  /* Ip address socket is going to be bind */
  String _ip;
  
  /* path for websocket */
  String _path;
  
  /* port to bind to */
  int _port;
  
  /* 2 second session timeout */
  int _sessionTimeout = 2;
  
  // 1 minute
  int _timerTickInterval = 6000;
  
  Logger logger = new Logger();
  
  /* Timer */
  Timer _timer;
  
  /* Store all method handlers in list */
  Map<String, Function> _methodHandlers;
  
  Server() {
    _httpServer = new HttpServer();
    _httpServer.sessionTimeout = _sessionTimeout;
    _wsHandler = new WebSocketHandler();
    _container = new UserContainer(this);
    _timer = new Timer.repeating(_timerTickInterval, onTimerTick);
    _methodHandlers = new Map<String, Function>();
    
    registerHandler("pong", handleIncomingPong);
    registerHandler("description", handleIncomingDescription);
    registerHandler("ice", handleIncomingIce);
  }
  
  void registerHandler(String type, Function handler) {
    if (_methodHandlers.containsKey(type))
      return;
    
    _methodHandlers[type] = handler;
  }
  
  Function getHandler(String type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return null;
    //return (Packet p) {
    //  logger.Error("No handler registered for packet ${p.packetType}");
    //};
  }
  
  void stop() {
    logger.Info("Stopping server");
    _timer.cancel();
    _httpServer.close();
  }
  
  void listen([String ip="0.0.0.0", int port=8234, String path="/ws"]) {
    _ip = ip;
    _path = path;
    _port = port;
    
    _httpServer.addRequestHandler((req) => req.path == _path, handler);
 
    _httpServer.onError = (err) {
      logger.Error(err);
    };
    run();
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
          
          if (p.packetType == "helo") {
            User u = _container.findUserByConn(conn);
            if (u != null) {
              conn.close(1003, "Already HELO'd");
              logger.Warning("User exists, disconnecting");
            }
          }
          
          Function f = getHandler(p.packetType);
          if (f != null) {
            print ("handler found");
            f(p, conn);
          } else {
            logger.Warning("Incoming packet ${p.packetType} but no handler registered");
          }
          
        };
        conn.onClosed = (int status, String reason) {
          logger.Debug('closed with $status for $reason');
          logger.Info(displayStatus());
        };
      
      } on Exception catch(e) {
        logger.Error("Error onMessage: $e");
      } catch(e) {
        logger.Error("Last catch onMessage: $e");
      }
    };
    
    _httpServer.listen(_ip, _port);
  }
  
  String displayStatus() {
    print("Users: ${_container.userCount}");
  }
  
  void onTimerTick(Timer t) {
    print("tick");
    try {
      displayStatus();
    _container.cleanUp();
    
    } catch(e) {
      print(e);
    }
  }
  
  void sendToClient(WebSocketConnection c, String p) {
    try {
      c.send(p);
    } catch(e) {
      logger.Debug("Socket Dead? removing connection");
      try {
        ChannelUser u = _container.findUserByConn(c) as ChannelUser;
        if (u != null) {
          _container.removeUser(u);
          u.channel.leave(u);
          u = null;
        }
        c.close(1000, "Assuming dead");
      } catch (e) {
        logger.Debug("Last catch, sendToClient $e");
      }
    }
  }
  
  void handleIncomingDescription(DescriptionPacket p, WebSocketConnection c) {
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    User receiver = _container.findUserById(p.userId);
    receiver.lastActivity = new Date.now().millisecondsSinceEpoch;
    
    if (sender == null || receiver == null) {
      logger.Warning("Sender or Receiver not found");
      return;
    }
    
    if (sender == receiver) {
      logger.Warning("Sending to self, abort");
      return;
    }
    
    logger.Debug("Desc from ${sender.id} to ${receiver.id}");
    receiver.send(JSON.stringify(new DescriptionPacket.With(p.sdp, p.type, sender.id, "")));
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
    
    logger.Debug("Ice from ${sender.id} to ${receiver.id}");
    receiver.send(JSON.stringify(new ICEPacket.With(ice.candidate, ice.sdpMid, ice.sdpMLineIndex, sender.id, "")));
  }
  
  void handleIncomingPong(PongPacket p, c) {
    logger.Debug("Handling pong");
    User sender = _container.findUserByConn(c);
    sender.lastActivity = new Date.now().millisecondsSinceEpoch;
    
  }
}
