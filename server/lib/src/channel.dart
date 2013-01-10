part of rtc_server;

class Channel {
  /* Parent container */
  ChannelContainer _container;
  
  /* Room id */
  String _id;
  
  /* max amount of users in room */
  int _limit;
  
  // TODO: needed?
  bool _hasBeenJoined = false;
  
  List<ChannelUser> _users;
  // returns true id users in room is less or equal than limit
  bool get canJoin => _users.length < _limit;
  int get userCount => _users.length;
  String get id => _id;
  
  /**
   * Default constructor
   */
  Channel(ChannelContainer rc, String id, int limit) {
    _id = id;
    _limit = limit;
    _container = rc;
    _users = new List<ChannelUser>();
  }
  
  /**
   * Joins the room
   * @param User joining the room
   */
  void join(ChannelUser newUser) {
    
    
    newUser.channel = this;
    _users.add(newUser);
    // Get the server
    Server server = _container.getServer();
    
    // Create a join packet to notify existing users in room
    //String jp = JSON.stringify(new JoinPacket.With(_id, newUser.id));
    Packet jp = new JoinPacket.With(_id, newUser.id);
    // Iterate trough all the users in this room
    _users.forEach((User u) {
      // If the newUser is not the current user in container 
      if (u != newUser) {
        // Create a Id packet sent to the newUser telling it all existing users in room
        Packet ip = new IdPacket.With(u.id, _id);
        
        // Send to client handles errors
        server.sendPacket(u.connection, jp);
        server.sendPacket(newUser.connection, ip);
      }
    });
  }
  
  void killAll() {
     
  }
  
  void leave(ChannelUser u) {
    u.channel = null;
    if (_users.contains(u))
      _users.removeAt(_users.indexOf(u));
    
    if (userCount <= 0)
      _container.removeChannel(this);
  }
  
  void sendToAll(String p) {
    _users.forEach((User u) {
        _container.getServer().sendToClient(u.connection, p);
    });
  }
  
  void sendToAllExceptSender(User sender, String p) {
    _users.forEach((User u) {
      if (sender != u) {
        _container.getServer().sendToClient(u.connection, p);
      }
    });
  }
  /**
   * Equality operator ==
   * Check that id strings match
   **/
  operator ==(Channel other) {
    return _id == other._id;
  }
}
