part of rtc_server;

class ChannelContainer extends BaseChannelContainer implements ChannelConnectionEventListener{
  /* logger singleton instance */
  Logger logger = new Logger();
  
  /* user limit for channels */
  int _channelLimit = 20;
  
  /** Amount of active channels */
  int get channelCount => _list.length;
  
  /**
   * Constructor
   * Takes Server as parameter
   */
  ChannelContainer(Server s) : super(s) {
   
  }
  
  
  void onEnterChannel(Channel c, User u) {
    
  }
  
  void onLeaveChannel(Channel c, User u) {
    logger.Debug("(channelcontainer.dart) User ${u.id} left channel ${c.id}");
    
    if (c.userCount == 0) {
      logger.Debug("(channelcontainer.dart) channel ${c.id} usercount is 0, removing channel");
      removeChannel(c);
    } else {
      logger.Debug("(channelcontainer.dart) channel ${c.id} usercount is ${c.userCount}");
    }
  }
  
  /**
   * Returns all users in channel
   */
  List<User> usersInChannel(Channel c) {
    return c._users;
  }
  
  List<Channel> getChannelsWhereUserIs(User u) {
    return _list.where((Channel c) => c.users.contains(u));
  }
  /**
   * Remove channel and kill users if any
   */
  bool removeChannel(Channel c) {
    logger.Debug("Removing Channel ${c.id}");
    
    if (_list.contains(c)) {
      if (c.userCount > 0)
        c.killAll();
      
      //c.unsubscribe(this);
      remove(c);
    }
  }
  
  /**
   * Find a channel by id
   */
  Channel findChannel(String id) {
    for (int i = 0; i < _list.length; i++) {
      Channel c = _list[i];
      if (c._id == id)
        return c;
    }
    
    return null;
  }
  
  /**
   * Return true if channel exists
   */
  bool channelExists(String id) {
    return findChannel(id) != null; 
  }
  
  /**
   * Create channel with random  id
   */
  Channel createChannel() {
    String id = Util.generateId(RANDOM_ID_LENGTH);
    return createChannelWithId(id);
  }
  
  /**
   * Create channel with specified id
   */
  Channel createChannelWithId(String id) {
    if (channelExists(id))
      return findChannel(id);
    
    Channel r = new Channel.With(this, id, _channelLimit);
    r.subscribe(this);
    add(r);
    //_list.add(r);
    
    return r;
  }

}
