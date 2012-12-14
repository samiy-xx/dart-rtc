part of rtc_server;

/**
 * User
 * Has WebSocketConnection, id and room attached
 */
class RoomUser extends User{
  
  /* Current room */
  Room _room = null;
  
  /** Getter for users current room */
  Room get room => _room;
  
  /** Setter for users current room */
  set room(Room value) => _room = value;
  
  /**
   * Constructor
   */
  RoomUser(String id, WebSocketConnection conn) : super(id, conn);
  
  /**
   * Sets a room for the user
   * @param r Room the user belongs to
   */
  void setRoom(Room r) {
    _room = r; 
  }
  
  /*
   * Override
   */
  void onClose(int status, String reason) {
    super._onClose(status, reason);
    _room.leave(this); 
  }
  
  
}
