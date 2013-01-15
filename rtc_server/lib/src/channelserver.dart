part of rtc_server;

class ChannelServer extends WebSocketServer implements ContainerContentsEventListener{
  ChannelContainer _channelContainer;
  
  ChannelServer() : super() {
    registerHandler("helo", handleHelo);
    registerHandler("bye", handleBye);
    registerHandler("peercreated", handlePeerCreated);
    registerHandler("usermessage", handleUserMessage);
    
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
  
  void handleHelo(HeloPacket hp, WebSocketConnection c) {
    try {
      if (hp.channelId == null || hp.channelId.isEmpty) {
        c.close(1003, "Specify channel id");
        return;
      }
      
      User u;
      if (hp.id != null && !hp.id.isEmpty)
        u = _container.createChannelUserFromId(hp.id, c);
      else
        u = _container.createChannelUser(c);
      
      sendToClient(c, PacketFactory.get(new ConnectionSuccessPacket.With(u.id)));
      
      Channel chan;
      chan = _channelContainer.findChannel(hp.channelId);
      if (chan != null) {
        if (chan.canJoin) {
          chan.join(u);
        } else {
          c.close(1003, "Channel was full");
          //_container.removeUser(u);
          //u = null;
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
  
  void handleBye(ByePacket bp, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    
    try {
      if (user != null) {
        //user.channel.leave(user);
        //_container.removeUser(user);
        user.terminate();
      }
    } catch(e) {
      print(e);
    }
  }

  void handlePeerCreated(PeerCreatedPacket pcp, WebSocketConnection c) {
    User user = _container.findUserByConn(c);
    User other = _container.findUserById(pcp.id);
    
    if (user != null && other != null)
      user.talkTo(other);
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
