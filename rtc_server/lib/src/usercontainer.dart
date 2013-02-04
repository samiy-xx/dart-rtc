part of rtc_server;

class UserContainer extends BaseUserContainer implements UserConnectionEventListener {
  /* logger singleton instance */
  Logger logger = new Logger();
  
  /** Returns a list of users */
  List<User> get users => _list;
  
  /** Number of users */
  int get userCount => _list.length;
  
  /**
   * Constructor
   */
  UserContainer(Server s) : super(s){
    
  }
  
  /**
   * Implements UserConnectionEventListener
   */
  void onClose(User u, int status, String reason) {
    logger.Debug("(usercontainer.dart) Removing user ${u.id}");
    removeUser(u);
  }
  
  /*
   * Generate random id
   */
  static String genId() {
    return Util.generateId(RANDOM_ID_LENGTH);
  }
  
  /**
   * Returns all users
   */
  List<User> getUsers() {
    return _list;
  }
  
  User createUser(WebSocketConnection c) {
    String id = genId();
    return createUserFromId(id, c);
  }
  
  User createUserFromId(String id, WebSocketConnection c) {
    User u = findUserById(id);
    
    if (u != null) 
      return u;
    
    u = new User.With(this, id, c);
    u.subscribe(this);
    //_list.add(u);
    add(u);
    return u;
  }
  
  /**
   * Removes the user specified
   */
  void removeUser(User u) {
    remove(u);
  }
  
  /**
   * Returns true if user exists in users list
   */
  bool userExist(User userToFind) {
    return _list.where((User u) => u == userToFind).length > 0; 
  }
  
  /**
   * Returns user that has been inactive longest
   */
  User findLongestIdUser(User caller) {
    List<User> toPick = _list.where((u) => u != caller && !u.isTalking);
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
    List<User> toPick = _list.where((u) => u != caller && !u.isTalking);
    
    if (toPick.length > 0) {
      Random r = new Random();
      int n = r.nextInt(toPick.length);
      
      return toPick[n > 0 ? n - 1 : n];
    }
    
    return null;
  }
  
  // Obsolete
  User findRandomUser_old(User caller) {
    for (int i = 0; i < _list.length; i++) {
      User u = _list[i];
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
    
    for(int i = 0; i < _list.length; i++) {
      if (_list[i].connection == c) {
        u = _list[i];
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
    
    for(int i = 0; i < _list.length; i++) {
      if (_list[i].id == id) {
        u = _list[i];
        break;
      }
    }
    
    return u;
  }
  
  
}
