part of rtc_server;

class UserContainer extends BaseUserContainer {
  /* Store users */
  List<User> _users;
  
  /* logger singleton instance */
  Logger logger = new Logger();
  
  int get userCount => _users.length;
  
  UserContainer(Server s) : super(s){
    _users = new List<User>();
  }
  
  /*
   * Generate random id
   */
  static String genId() {
    return Util.generateId();
  }
  
  ChannelUser createChannelUser(WebSocketConnection c) {
    String id = genId();
    return createChannelUserFromId(id, c);
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
  
  ChannelUser createChannelUserFromId(String id, WebSocketConnection c) {
    
    ChannelUser u = findUserById(id);
    
    if (u != null) 
      return u;
    
    u = new ChannelUser(id, c);
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
  
  User findLongestIdUser(User caller) {
    List<User> toPick = _users.filter((u) => u != caller && !u.isTalking);
    
    if (toPick.length > 0) {
      toPick.sort((a, b) => a.compareTo(b));
      return toPick.last;
    }
    
    return null;
  }
  
  User findRandomUser(User caller) {
    List<User> toPick = _users.filter((u) => u != caller && !u.isTalking);
    
    if (toPick.length > 0) {
      Random r = new Random();
      int n = r.nextInt(toPick.length);
      
      return toPick[n > 0 ? n - 1 : n];
    }
    
    return null;
  }
  
  User findRandomUser_old(User caller) {
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      if (!u.isTalking && u != caller) {
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
    //logger.Debug("Users active: ${_users.length}");
    
    int currentTime = new Date.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      if (currentTime >= u.lastActivity + DEAD_SOCKET_CHECK && currentTime < u.lastActivity + DEAD_SOCKET_KILL) {
        _server.sendPacket(u.connection, new PingPacket.With(u.id));
      } else if(currentTime >= u.lastActivity + DEAD_SOCKET_KILL) {
        try {
          logger.Debug("Closing dead socket");
          u.connection.close(1000, "Closing dead socket");
          if (u is ChannelUser) {
            (u as ChannelUser).channel.leave(u);
            
          }
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
