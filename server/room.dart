part of rtc_server;

class Room {
  /* Parent container */
  Container container;
  
  /* Room id */
  String id;
  
  /* max amount of users in room */
  int limit;
  
  // TODO: needed?
  bool _hasBeenJoined = false;
  
  // returns true id users in room is less or equal than limit
  bool get canJoin => container.usersInRoom(this).length <= limit;
  int get userCount => container.usersInRoom(this).length;
  /**
   * Default constructor
   */
  Room() {
    id = "Default";
    limit = 5;
  }
  
  /**
   * Constructor with params
   */
  Room.With(this.id, this.limit);
  
  /**
   * Joins the room
   * @param User joining the room
   */
  void join(User newUser) {
    if (!canJoin)
      return;
    
    newUser.room = this;
    // Get the server
    Server server = container.getServer();
    
    // Create a join packet to notify existing users in room
    String jp = JSON.stringify(new JoinPacket.With(id, newUser.id));
    
    // Iterate trough all the users in this room
    container.usersInRoom(this).forEach((User u) {
      // If the newUser is not the current user in container 
      if (u != newUser) {
        // Create a Id packet sent to the newUser telling it all existing users in room
        String ip = JSON.stringify(new IdPacket.With(u.id, id));
        
        // Send to client handles errors
        server.sendToClient(u.connection, jp);
        server.sendToClient(newUser.connection, ip);
      }
    });
  }
  
  void leave(User u) {
    u.room = null;
    if (userCount <= 0)
      container.removeRoom(this);
  }
  
  void sendToAll(String p) {
    container.usersInRoom(this).forEach((User u) {
        container.getServer().sendToClient(u.connection, p);
    });
  }
  
  void sendToAllExceptSender(User sender, String p) {
    container.usersInRoom(this).forEach((User u) {
      if (sender != u) {
        container.getServer().sendToClient(u.connection, p);
      }
    });
  }
  /**
   * Equality operator ==
   * Check that id strings match
   **/
  operator ==(Room other) {
    return id == other.id;
  }
}
