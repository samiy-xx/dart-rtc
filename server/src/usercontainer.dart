part of rtc_server;

class UserContainer {
  /* Store users */
  List<User> _users;
  
  /* Reference to Server */
  Server _server;
  
  /* logger singleton instance */
  Logger logger = new Logger();
  
  int get userCount => _users.length;
  
  UserContainer(Server s) {
    _users = new List<RoomUser>();
    _server = s;
  }
  
  /**
   * Method to return instance of the Server
   */
  Server getServer() {
    return _server; 
  }
  
  /*
   * Generate random id
   */
  static String genId() {
    return Util.generateId();
  }
  
  User createUser(WebSocketConnection c) {
    String id = genId();
    return createUserFromId(id, c);
  }
  
  User createUserFromId(String id, WebSocketConnection c) {
    
    User u = findUserById(id);
    
    if (u != null) 
      return u;
    
    u = new User(id, c);
    _users.add(u);
    
    u.connection.onClosed = (int code, String reason) {
      removeUser(u);
    };
    return u;
  }
  
  void removeUser(User u) {
    if (_users.contains(u)) {
      _users.removeAt(_users.indexOf(u));
    }
  }
  
  bool userExist(User userToFind) {
    return _users.filter((User u) => u == userToFind).length > 0; 
  }
  
  User findRandomUser() {
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      if (!u.isTalking) {
        return u;
      }
    }
    
    return null;
  }
  
  User findUserByConn(WebSocketConnection c) {
    User u = null;
    
    for(int i = 0; i < _users.length; i++) {
      if (_users[i].connection == c) {
        u = _users[i];
        break;
      }
    }
    
    return u;
  }
// TODO: make this match both id and connection
  User findUserById(String id) {
    User u = null;
    
    for(int i = 0; i < _users.length; i++) {
      if (_users[i].id == id) {
        u = _users[i];
        break;
      }
    }
    
    return u;
  }
  void cleanUp() {
    logger.Debug("Users active: ${_users.length}");
    
    int currentTime = new Date.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      if (currentTime >= u.lastActivity + DEAD_SOCKET_CHECK && currentTime < u.lastActivity + DEAD_SOCKET_KILL) {
        _server.sendToClient(u.connection, JSON.stringify(new PingPacket.With(u.id)));
      } else if(currentTime >= u.lastActivity + DEAD_SOCKET_KILL) {
        try {
          logger.Debug("Closing dead socket");
          u.connection.close(1000, "Closing dead socket");
        } catch (e) {
          logger.Error("Closing dead socket threw $e");
        }
        logger.Debug("Removing references to dead object");
     
        removeUser(u);
        //u.room = null;
        u = null;
      }
    }
  }
}
