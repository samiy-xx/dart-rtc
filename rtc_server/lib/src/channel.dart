part of rtc_server;

class Channel extends GenericEventTarget<ChannelEventListener> implements UserConnectionEventListener {
  /* Parent container */
  ChannelContainer _container;
  
  /* Room id */
  String _id;
  
  /* max amount of users in room */
  int _limit;
  
  // TODO: needed?
  bool _hasBeenJoined = false;
  
  List<User> _users;
  
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
    _users = new List<User>();
  }
  
  /**
   * Implements UserConnectionEventListener
   */
  void onClose(User u, int status, String reason) {
    new Logger().Debug("(channel.dart) onClose fired for user ${u.id}");
    leave(u);
  }
  /**
   * Joins the room
   * @param User joining the room
   */
  void join(User newUser) {
    //newUser.channel = this;
    _users.add(newUser);
    newUser.subscribe(this);
    new Logger().Debug("User ${newUser.id} joins channel $_id");
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
  
  void leave(User u) {
    new Logger().Debug("(channel.dart) User ${u.id} leaving channel $id");
    
    //u.channel = null;
    if (_users.contains(u))
      _users.removeAt(_users.indexOf(u));
    
    if (userCount <= 0) {
      print("Usercount ${userCount} removing channel");
      _container.removeChannel(this);
    }
  }
  
  void sendToAll(Packet p) {
    _users.forEach((User u) {
        _container.getServer().sendPacket(u.connection, p);
    });
  }
  
  void sendToAllExceptSender(User sender, Packet p) {
    _users.forEach((User u) {
      if (sender != u) {
        _container.getServer().sendPacket(u.connection, p);
      }
    });
  }
  /**
   * Equality operator ==
   * Check that id strings match
   **/
  operator ==(Object other) {
    if (!(other is Channel)) {
      new Logger().Warning("(channel.dart) operator== tried to match against ${other.runtimeType.toString()}");
      return false;
    }
    return _id == (other as Channel)._id;
  }
}
