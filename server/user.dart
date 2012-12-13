part of rtc_server;

/**
 * User
 * Has WebSocketConnection, id and room attached
 */
class User {
  List<User> _talkingTo;
  /* name (id) of the user */
  String _id;
  
  /* WebSocketConnection */
  WebSocketConnection _conn;
  
  /* Current room */
  Room _room = null;
  
  bool _canRoute = true;
  int _lastActivity;
  
  int get lastActivity => _lastActivity;
  
  /** Getter for user id */
  String get id => _id;
  
  /** Getter for the connection */
  WebSocketConnection get connection => _conn;
  
  bool get canRoute => _canRoute;
  /** Getter for users current room */
  Room get room => _room;
  
  /** Setter for user id */
  set id(String value) => _id = value;
  
  /** Setter for users current room */
  set room(Room value) => _room = value;
  
  set lastActivity(int value) => _lastActivity = value;
  
  Logger log = new Logger();
  /**
   * Constructor
   */
  User(this._id, this._conn) {
    _talkingTo = new List<User>();
    _conn.onClosed = onClose;
    _lastActivity = new Date.now().millisecondsSinceEpoch;
  }
  
  /**
   * Sets a room for the user
   * @param r Room the user belongs to
   */
  void setRoom(Room r) {
    _room = r; 
  }
  
  void onClose(int status, String reason) {
    log.Debug("User, connection closed");
    _room.leave(this); 
    _talkingTo.forEach((User u) => u.hangup(this));
  }
  
  void hangup(User u) {
    if (_talkingTo.contains(u))
      _talkingTo.removeAt(_talkingTo.indexOf(u));
  }
  
  void talkTo(User u) {
    if (_talkingTo.contains(u))
      return;
    
    u.talkTo(this);
    _talkingTo.add(u);
  }
  
  void terminate() {
    try {
      _conn.close(1000, "Leaving");
    } on Exception catch(e) {
      log.Error(e.toString());
    } catch (e) {
      log.Error(e);
    }
  }
  void send(String p) {
   _conn.send(p); 
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
