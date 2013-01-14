part of rtc_server;

class ChannelContainer extends BaseChannelContainer {
  /* Store all channels in list */
  List<Channel> _channels;
 
  /* logger singleton instance */
  Logger logger = new Logger();
  
  /* user limit for channels */
  int _channelLimit = 20;
  
  /** Amount of active channels */
  int get channelCount => _channels.length;
  
  /**
   * Constructor
   * Takes Server as parameter
   */
  ChannelContainer(Server s) : super(s) {
    _channels = new List<Channel>();
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
    if (_channels.contains(c)) {
      if (c.userCount > 0)
        c.killAll();
      
      _channels.removeAt(_channels.indexOf(c));
    }
  }
  
  /**
   * Find a channel by id
   */
  Channel findChannel(String id) {
    for (int i = 0; i < _channels.length; i++) {
      Channel c = _channels[i];
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
    String id = Util.generateId();
    return createChannelWithId(id);
  }
  
  /**
   * Create channel with specified id
   */
  Channel createChannelWithId(String id) {
    if (channelExists(id))
      return findChannel(id);
    
    Channel r = new Channel(this, id, _channelLimit);
    _channels.add(r);
    
    return r;
  }
  
  /**
   * Create queue enabled channel with specified id
   */
  Channel createQueueChannel(String id) {
    if (channelExists(id))
      return findChannel(id);
    
    Channel r = new QueueChannel(this, id);
    _channels.add(r);
    
    return r;
  }
}
