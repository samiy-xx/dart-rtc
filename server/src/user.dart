part of rtc_server;

/**
 * User class
 */
class User implements Comparable {
  /* talking to */
  List<User> _talkingTo;
  
  /* name (id) of the user */
  String _id;
  
  /* WebSocketConnection */
  WebSocketConnection _conn;
  
  /* millisecond timestamp when last activity was registered*/
  int _lastActivity;
  
  /* millisecond timestamp when last connection to another user was done */
  int _timeSinceLastConnection;
  
  /** millisecond timestamp when last activity was registered */
  int get lastActivity => _lastActivity;
  
  /** millisecond timestamp when last connection to another user was done */
  int get timeSinceLastConnection => _timeSinceLastConnection;
  
  /** Is the user talking to another user */ 
  bool get isTalking => _talkingTo.length > 0;
  
  /** Users this user it talking with */
  List<User> get talkers => _talkingTo;
  
  /** Getter for user id */
  String get id => _id;
  
  /** Getter for the connection */
  WebSocketConnection get connection => _conn;
  
  /** Setter for user id */
  set id(String value) => _id = value;
  
  /** Set the timestamp for last activity */
  set lastActivity(int value) => _lastActivity = value;
  
  /** Set the timestamp for last connection */
  set timeSinceLastConnection(int value) => _timeSinceLastConnection = value;
  
  /** Logger =) */
  Logger log = new Logger();
  
  /**
   * Constructor
   */
  User(this._id, this._conn) {
    _talkingTo = new List<User>();
    _conn.onClosed = _onClose;
    _lastActivity = new Date.now().millisecondsSinceEpoch;
    _timeSinceLastConnection = new Date.now().millisecondsSinceEpoch;
  }
 
  /*
   * Called when websocket connection closes
   */ 
  void _onClose(int status, String reason) {
    log.Debug("User, connection closed");
    _talkingTo.forEach((User u) => u.hangup(this));
  }
  
  /**
   * Hangup with other users
   */
  void hangup(User u) {
    if (_talkingTo.contains(u))
      _talkingTo.removeAt(_talkingTo.indexOf(u));
  }
  
  /**
   * Talk to other user
   */
  void talkTo(User u) {
    if (!_talkingTo.contains(u)) {
      //u.talkTo(this);
      _talkingTo.add(u);
    }
  }
  
  /**
   * Kill the user
   */
  void terminate() {
    try {
      _conn.close(1000, "Leaving");
    } on Exception catch(e) {
      log.Error(e.toString());
    } catch (e) {
      log.Error(e);
    }
  }
  
  /**
   * Send data to this user over web socket connection
   */
  void send(String p) {
   _conn.send(p); 
  }
  
  /**
   * Implements Comparable
   */
  int compareTo(Comparable other) {
    if (!(other is User))
      throw new ArgumentError("Cannot compare to anything else but User");
    
    int toReturn;
    
    if (_timeSinceLastConnection < other.timeSinceLastConnection)
      toReturn = -1;
    else if (_timeSinceLastConnection > other.timeSinceLastConnection)
      toReturn = 1;
    else
      toReturn = 0;
    
    return toReturn;
  }
  
  operator >(User other) {
    return _timeSinceLastConnection > other.timeSinceLastConnection;
  }
  
  operator >=(User other) {
    return _timeSinceLastConnection >= other.timeSinceLastConnection;
  }
  
  /**
   * Equality operator ==
   */
  operator ==(Object o) {
    if (!(o is User))
      return false;
    
    User u = o as User;
    if (u._conn != this._conn || u._id != this._id) {
      return false;
    }
    
    return true;
  }
}
