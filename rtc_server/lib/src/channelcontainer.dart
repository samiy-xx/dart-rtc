part of rtc_server;

class ChannelContainer extends BaseChannelContainer {
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
  
  /**
   * Returns all users in channel
   */
  List<User> usersInChannel(Channel c) {
    return c._users;
  }
  
  /**
   * Remove channel and kill users if any
   */
  bool removeChannel(Channel c) {
    if (_list.contains(c)) {
      if (c.userCount > 0)
        c.killAll();
      
      remove(c);
      //_list.removeAt(_list.indexOf(c));
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
    
    Channel r = new Channel(this, id, _channelLimit);
    add(r);
    //_list.add(r);
    
    return r;
  }

}
