part of rtc_server;

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
  
  Map<String, Function> _methodHandlers;
  
  Server() {
    _httpServer = new HttpServer();
    _httpServer.sessionTimeout = _sessionTimeout;
    _wsHandler = new WebSocketHandler();
    _container = new Container(this);
    _timer = new Timer.repeating(_timerTickInterval, onTimerTick);
    _methodHandlers = new Map<String, Function>();
  }
  
  void registerHandler(String type, Function handler) {
    if (_methodHandlers.containsKey(type))
      return;
    
    _methodHandlers[type] = handler;
  }
  
  Function getHandler(String type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return (Packet p) {
      logger.Error("No handler registered for packet ${p.packetType}");
    };
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
          f(p, conn);
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
    StringBuffer buffer = new StringBuffer();
    buffer.add("Users: ${_container.userCount} Rooms: ${_container.roomCount}");
    return buffer.toString();
  }
  
  void onTimerTick(Timer t) {
    _container.cleanUp();
  }
  
  void sendToClient(WebSocketConnection c, String p) {
    try {
      c.send(p);
    } catch(e) {
      logger.Debug("Socket Dead? removing connection");
      try {
        RoomUser u = _container.findUserByConn(c);
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
}
