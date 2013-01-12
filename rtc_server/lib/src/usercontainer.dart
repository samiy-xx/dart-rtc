part of rtc_server;

class UserContainer extends BaseUserContainer {
  /* Store users */
  List<User> _users;
  
  /* logger singleton instance */
  Logger logger = new Logger();
  
  /** Returns a list of users */
  List<User> get users => _users;
  
  /** Number of users */
  int get userCount => _users.length;
  
  /**
   * Constructor
   */
  UserContainer(Server s) : super(s){
    _users = new List<User>();
  }
  
  /*
   * Generate random id
   */
  static String genId() {
    return Util.generateId();
  }
  
  /**
   * Returns all users
   */
  List<User> getUsers() {
    return _users;
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
    
    u = new User(this, id, c);
    _users.add(u);
    
    return u;
  }
  
  ChannelUser createChannelUserFromId(String id, WebSocketConnection c) {
    ChannelUser u = findUserById(id);
    
    if (u != null) 
      return u;
    
    u = new ChannelUser(this, id, c);
    _users.add(u);

    return u;
  }
  
  /**
   * Removes the user specified
   */
  void removeUser(User u) {
    if (_users.contains(u)) {
      _users.removeAt(_users.indexOf(u));
    }
  }
  
  /**
   * Returns true if user exists in users list
   */
  bool userExist(User userToFind) {
    return _users.filter((User u) => u == userToFind).length > 0; 
  }
  
  /**
   * Returns user that has been inactive longest
   */
  User findLongestIdUser(User caller) {
    List<User> toPick = _users.filter((u) => u != caller && !u.isTalking);
    if (toPick.length > 0) {
      toPick.sort((a, b) => a.compareTo(b));
      return toPick.last;
    }
    
    return null;
  }
  
  /**
   * Returns a random user
   */
  User findRandomUser(User caller) {
    List<User> toPick = _users.filter((u) => u != caller && !u.isTalking);
    
    if (toPick.length > 0) {
      Random r = new Random();
      int n = r.nextInt(toPick.length);
      
      return toPick[n > 0 ? n - 1 : n];
    }
    
    return null;
  }
  
  // Obsolete
  User findRandomUser_old(User caller) {
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      if (!u.isTalking && u != caller) {
        return u;
      }
    }
    
    return null;
  }
  
  /**
   * Retuns a user with matching WebSocketConnection instance
   */
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

  /**
   * Returns a user with matching id property
   */
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
  
  
}
