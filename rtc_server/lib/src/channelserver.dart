part of rtc_server;

class ChannelServer extends WebSocketServer implements ContainerContentsEventListener{
  ChannelContainer _channelContainer;
  
  ChannelServer() : super() {
    registerHandler(PacketType.PEERCREATED, handlePeerCreated);
    registerHandler(PacketType.USERMESSAGE, handleUserMessage);
    registerHandler(PacketType.CHANNELMESSAGE, handleChannelMessage);
    
    _channelContainer = new ChannelContainer(this);
    _channelContainer.subscribe(this);
  }
  
  void onCountChanged(BaseContainer bc) {
    new Logger().Info("Container count changed ${bc.count}");
    displayStatus();
  }
  
  String displayStatus() {
    new Logger().Info("Users: ${_container.userCount} Channels: ${_channelContainer.channelCount}");
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
      
      Channel chan;
      chan = _channelContainer.findChannel(hp.channelId);
      if (chan != null) {
        if (chan.canJoin) {
          chan.join(u);
        } else {
          c.close(1003, "Channel was full");
          
          return;
        }
      } else {
        chan = _channelContainer.createChannelWithId(hp.channelId);
        chan.join(u);
      }
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
  void handleChannelMessage(ChannelMessage cm, WebSocketConnection c) {
    try {
      
      if (cm.channelId == null || cm.channelId.isEmpty) 
        return;
      
      User user = _container.findUserByConn(c);
      
      if (user == null) {
        new Logger().Warning("(channelserver.dart) User was not found");
        return;
      }
      
      Channel channel = _channelContainer.findChannel(cm.channelId);
      if (channel.isInChannel(user)) {
        channel.sendToAllExceptSender(user, cm);
      }
      
    } on NoSuchMethodError catch(e) {
      new Logger().Error("Error: $e");
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
      
      List<Channel> channels = _channelContainer.getChannelsWhereUserIs(user);
      if (channels.length > 0) {
        channels.forEach((Channel c) {
          c.sendToAllExceptSender(user, um);
        });
      }
      //um.id = user.id;
      
      
      //sendToClient(other.connection, PacketFactory.get(um));
      
    } on NoSuchMethodError catch(e) {
      new Logger().Error("Error: $e");
    } catch(e) {
      new Logger().Error("Error: $e");
    }
  }
}
