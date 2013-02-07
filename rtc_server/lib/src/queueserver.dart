part of rtc_server;

class QueueServer extends WebSocketServer implements ContainerContentsEventListener {
  QueueContainer _queueContainer;
  
  QueueServer() : super() {
    
    registerHandler(PacketType.PEERCREATED, handlePeerCreated);
    registerHandler(PacketType.USERMESSAGE, handleUserMessage);
    registerHandler(PacketType.NEXT, handleNextUser);
    registerHandler(PacketType.REMOVEUSER, handleRemoveUserCommand);
    
    _queueContainer = new QueueContainer(this);
    _queueContainer.subscribe(this);
  }
  
  
  void onCountChanged(BaseContainer bc) {
    new Logger().Info("Container count changed ${bc.count}");
    displayStatus();
  }
  
  String displayStatus() {
    new Logger().Info("Users: ${_container.userCount} Channels: ${_queueContainer.channelCount}");
  }
  
  // Override
  void handleIncomingHelo(HeloPacket hp, WebSocketConnection c) {
    super.handleIncomingHelo(hp, c);
    try {
      if (hp.channelId == null || hp.channelId.isEmpty) {
        c.close(1003, "Specify channel id");
        return;
      }
      
      User u = _container.findUserByConn(c);
      
      Channel chan = _queueContainer.findChannel(hp.channelId);
      if (chan == null)
        chan = _queueContainer.createChannelWithId(hp.channelId);
      chan.join(u); 
    } catch(e, s) {
      new Logger().Error(e);
      new Logger().Info(s);
    }
  }
  
  void handlePeerCreated(PeerCreatedPacket pcp, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    User other = _container.findUserById(pcp.id);
    
    if (user != null && other != null)
      user.talkTo(other);
  }

  void handleRemoveUserCommand(RemoveUserCommand p, WebSocketConnection c) {
    try {
      User user = _container.findUserByConn(c);
      User other = _container.findUserById(p.id);
      
      if (user == null || other == null) {
        new Logger().Warning("(channelserver.dart) User was not found");
        return;
      }
      
      Channel channel = _queueContainer.findChannel(p.channelId);
      if (user == channel.owner)
        channel.leave(other);
    } catch(e) {
      new Logger().Error("Error: $e");
    }
  }
  
  void handleNextUser(NextPacket p, WebSocketConnection c) {
    try {
      User user = _container.findUserByConn(c);
      User other = _container.findUserById(p.id);
      
      if (user == null || other == null) {
        new Logger().Warning("(channelserver.dart) User was not found");
        return;
      }
      
      QueueChannel channel = _queueContainer.findChannel(p.channelId);
      if (user == channel.owner)
        channel.next();
    } catch(e) {
      new Logger().Error("Error: $e");
    }
  }
  
  void handleUserMessage(UserMessage um, WebSocketConnection c) {
    try {
      if (um.id == null || um.id.isEmpty) {
        print ("id was null or empty");
        return;
      }
      User user = _container.findUserByConn(c);
      User other = _container.findUserById(um.id);
      
      if (user == null || other == null) {
        new Logger().Warning("(channelserver.dart) User was not found");
        return;
      }
      
      um.id = user.id;
      
      sendToClient(other.connection, PacketFactory.get(um));
      
    } on NoSuchMethodError catch(e) {
      new Logger().Error("Error: $e");
    } catch(e) {
      new Logger().Error("Error: $e");
    }
  }
}

