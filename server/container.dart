part of rtc_server;

class Container {
  /* Store users */
  List<RoomUser> _users;
  
  /* Store rooms */
  List<Room> _rooms;
  
  /* Reference to Server */
  RoomServer _server;
  
  /* logger singleton instance */
  Logger logger = new Logger();
  
  int get userCount => _users.length;
  int get roomCount => _rooms.length;
  /*
   * Default constructor
   * @param Server
   */
  Container(Server s) {
    _users = new List<RoomUser>();
    _rooms = new List<Room>();
    _server = s;
  }
  
  /**
   * Method to return instance of the Server
   */
  RoomServer getServer() {
    return _server; 
  }
  
  /*
   * Generate random id
   */
  static String genId() {
    return Util.generateId();
  }
  
  
  void cleanUp() {
    
    logger.Debug("Users active: ${_users.length} Rooms active: ${_rooms.length}");
    
    int currentTime = new Date.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < _users.length; i++) {
      RoomUser u = _users[i];
      if (currentTime >= u.lastActivity + DEAD_SOCKET_CHECK && currentTime < u.lastActivity + DEAD_SOCKET_KILL) {
        _server.sendToClient(u.connection, JSON.stringify(new PingPacket.With(u.id, u.room.id)));
      } else if(currentTime >= u.lastActivity + DEAD_SOCKET_KILL) {
        try {
          logger.Debug("Closing dead socket");
          u.connection.close(1000, "Closing dead socket");
        } catch (e) {
          logger.Error("Closing dead socket threw $e");
        }
        logger.Debug("Removing references to dead object");
        u.room.leave(u);
        removeUser(u);
        //u.room = null;
        u = null;
      }
    }
    
    try {
    for (int i = 0; i < _rooms.length; i++) {
      
      Room r = _rooms[i];
      if (usersInRoom(r) == 0) {
        _rooms.removeAt(_rooms.indexOf(r));
      }
    }
    } catch (e) {
      logger.Error(e);
    }
  }
  
  RoomUser createUser(WebSocketConnection c) {
    String id = genId();
    return createUserFromId(id, c);
  }
  
  RoomUser createUserFromId(String id, WebSocketConnection c) {
    
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
  
  void removeUser(RoomUser u) {
    if (_users.contains(u)) {
      _users.removeAt(_users.indexOf(u));
      
      if (u.room != null)
      u.room.leave(u);
      //u = null;
    }
  }
  
  bool userExist(RoomUser userToFind) {
    return _users.filter((RoomUser u) => u == userToFind).length > 0; 
  }
  
  RoomUser findUserByConn(WebSocketConnection c) {
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
  RoomUser findUserById(String id) {
    
    User u = null;
    
    for(int i = 0; i < _users.length; i++) {
      
      if (_users[i].id == id) {
        
        u = _users[i];
        break;
      }
    }
    
    return u;
  }
  
  List<RoomUser> usersInRoom(Room r) {
    return _users.filter((RoomUser u) => u._room == r);
  }
  
  
  /**
   * Finds room in container by id
   */
  Room findRoom(String id) {
    for(int i = 0; i < _rooms.length; i++) {
      Room r = _rooms[i];
      if (r.id == id)
        return r;
    }
    
    return null;
  }
  
  void removeRoom(Room r) {
    if (_rooms.contains(r)) {
      _rooms.removeAt(_rooms.indexOf(r));
    }
  }
  /**
   * Creates a room with random id
   */
  Room createRoom() {
    String id = Util.generateId();
    return createRoomWithId(id, 5);
  }
  
  Room createRoomWithId(String id, int limit) {
    
    Room r = new Room.With(id, limit);
    r.container = this;
    _rooms.add(r);
    
    return r;
  }
  
}
