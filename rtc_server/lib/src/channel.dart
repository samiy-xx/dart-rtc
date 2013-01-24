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
  
  /* Owner of the channel */
  User _owner;
  
  /* users */
  List<User> _users;
  
  /**
   * Returns true if users length is less than limit
   */
  bool get canJoin => _users.length < _limit;
  
  /**
   * Limit of users in channel
   */
  int get channelLimit => _limit;
  
  /**
   * Current usercount
   */
  int get userCount => _users.length;
  
  /**
   * Channel id
   */
  String get id => _id;
  
  Channel(String id, int limit) : this.With(null, id, limit);
  Channel.With(ChannelContainer rc, String id, int limit) {
    _id = id;
    _limit = limit;
    _users = new List<User>();
    _container = rc;
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
   */
  void join(User u) {
    if (_addUser(u)) {
      
      if (_users.length == 0)
        _owner = u;
      
      u.subscribe(this);
      new Logger().Debug("User ${u.id} joins channel $_id");
      
      _notifyUserJoined(u);
      
      _sendJoinPackets(u);
    }
  }
  
  void _sendJoinPackets(User user) {
    if (_container == null)
      return;
    
    // Get the server
    Server server = _container.getServer();
    
    // Create a join packet to notify existing users in room
    Packet jp = new JoinPacket.With(_id, user.id);
    
    // Iterate trough all the users in this room
    _users.forEach((User u) {
      // If the newUser is not the current user in container 
      if (u != user) {
        
        // Create a Id packet for newUser notifying all existing users in channel
        Packet ip = new IdPacket.With(u.id, _id);
        
        server.sendPacket(u.connection, jp);
        server.sendPacket(user.connection, ip);
      }
    });
  }
  /**
   * Remove user from channel
   * Notify everyone else in channel
   * Notify listeners
   */
  void leave(User u) {
    new Logger().Debug("(channel.dart) User ${u.id} leaving channel $id");
    
    _removeUser(u);
    _notifyUserLeft(u);
    
    sendToAll(new ByePacket.With(u.id));
    
    if (_container != null) {
      if (userCount <= 0) {
        print("Usercount ${userCount} removing channel");
        _container.removeChannel(this);
      }
    }
  }
  
  /**
   * Force all users to leave the channel
   */
  void killAll() {
    for (int i = 0; i < _users.length; i++) {
      User u = _users[i];
      leave(u);
    }
  }
  
  /*
   * Adds a user to channel if user does not exist already
   */
  bool _addUser(User u) {
    if (!_users.contains(u)) {
      _users.add(u);
      return true;
    }
    return false;
  }
  
  /*
   * Removes user from channel
   */
  User _removeUser(User u) {
    int index = _users.indexOf(u);
    if (index >= 0) {
      return _users.removeAt(index);
    }
    return null;
  }
  
  /*
   * Notify listeners about the user leaving
   */
  void _notifyUserLeft(User u) {
    listeners.where((l) => l is ChannelConnectionEventListener).forEach((ChannelConnectionEventListener l) {
      l.onLeaveChannel(this, u);
    });
  }
  
  /*
   * Notify listeners about the user joining
   */
  void _notifyUserJoined(User u) {
    listeners.where((l) => l is ChannelConnectionEventListener).forEach((ChannelConnectionEventListener l) {
      l.onEnterChannel(this, u);
    }); 
  }
  
  /**
   * Send packet to everyone in channel
   */
  void sendToAll(Packet p) {
    if (_container == null)
      return;
    
    _users.forEach((User u) {
        _container.getServer().sendPacket(u.connection, p);
    });
  }
  
  /**
   * Send packet to everyone in channel except the sender
   */
  void sendToAllExceptSender(User sender, Packet p) {
    if (_container == null)
      return;
    
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
