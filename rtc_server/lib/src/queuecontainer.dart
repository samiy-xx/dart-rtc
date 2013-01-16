part of rtc_server;

class QueueContainer extends ChannelContainer implements ChannelQueueEventListener {
  
  QueueContainer(Server s) : super(s) {
    _channelLimit = 2;
  }
  
  void onEnterQueue(Channel c, User u, int count, int position) {
    new Logger().Debug("User ${u.id} enters queue with $count users at position $position");
    _server.sendPacket(u.connection, new QueuePacket.With(u.id, c.id, position.toString()));
  }
  
  void onMoveInQueue(Channel c, User u, int count, int position) {
    new Logger().Debug("User ${u.id} moves in queue with $count users at position $position");
    _server.sendPacket(u.connection, new QueuePacket.With(u.id, c.id, position.toString()));
  }
  
  void onLeaveQueue(Channel c, User u) {
    new Logger().Debug("User ${u.id} leaves queue");
    _server.sendPacket(u.connection, new QueuePacket.With(u.id, c.id, "0"));
  }
  
  /**
   * Create channel with specified id
   */
  Channel createChannelWithId(String id) {
    if (channelExists(id))
      return findChannel(id);
    
    Channel c = new QueueChannel(this, id);
    c.subscribe(this);
    add(c);
    return c;
  }
}

