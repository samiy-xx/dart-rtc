part of rtc_server;

class ChannelContainer extends BaseChannelContainer {
  List<Channel> _channels;
 
  /* logger singleton instance */
  Logger logger = new Logger();
  
  int get channelCount => _channels.length;
  
  int _channelLimit = 2;
  
  ChannelContainer(Server s) : super(s) {
    _channels = new List<Channel>();
  }
  
  List<ChannelUser> usersInChannel(Channel c) {
    return c._users;
  }
  
  bool removeChannel(Channel c) {
    if (_channels.contains(c)) {
      if (c.userCount > 0)
        c.killAll();
      
      _channels.removeAt(_channels.indexOf(c));
    }
  }
  
  Channel findChannel(String id) {
    for (int i = 0; i < _channels.length; i++) {
      Channel c = _channels[i];
      if (c._id == id)
        return c;
    }
    
    return null;
  }
  
  bool channelExists(String id) {
    return findChannel(id) != null; 
  }
  
  Channel createChannel() {
    String id = Util.generateId();
    return createChannelWithId(id);
  }
  
  
  Channel createChannelWithId(String id) {
    if (channelExists(id))
      return findChannel(id);
    
    Channel r = new Channel(this, id, _channelLimit);
    _channels.add(r);
    
    return r;
  }
}
