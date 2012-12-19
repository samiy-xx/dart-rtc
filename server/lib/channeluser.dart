part of rtc_server;

/**
 * User
 * Has WebSocketConnection, id and room attached
 */
class ChannelUser extends User{
  
  /* Current room */
  Channel _channel = null;
  
  /** Getter for users current room */
  Channel get channel => _channel;
  
  /** Setter for users current room */
  set channel(Channel value) => setChannel(value);
  
  /**
   * Constructor
   */
  ChannelUser(String id, WebSocketConnection conn) : super(id, conn);
  
  /**
   * Sets a room for the user
   * @param r Room the user belongs to
   */
  void setChannel(Channel c) {
    _channel = c; 
  }
  
  /*
   * Override
   */
  void onClose(int status, String reason) {
    super._onClose(status, reason);
    _channel.leave(this); 
  }
  
}
