part of rtc_server;

class ChannelServer extends Server {
  ChannelContainer _channelContainer;
  
  ChannelServer() : super() {
    registerHandler("helo", handleHelo);
    registerHandler("bye", handleBye);
    registerHandler("peercreated", handlePeerCreated);
    registerHandler("usermessage", handleUserMessage);
    
    _channelContainer = new ChannelContainer(this);
  }
  
  String displayStatus() {
    
  
    print("Users: ${_container.userCount} Channels: ${_channelContainer.channelCount}");
    
  }
  
  void handleHelo(HeloPacket hp, WebSocketConnection c) {
    try {
      if (hp.channelId == null || hp.channelId.isEmpty) {
        c.close(1003, "Specify channel id");
        return;
      }
      
      ChannelUser u;
      if (hp.id != null && !hp.id.isEmpty)
        u = _container.createChannelUserFromId(hp.id, c);
      else
        u = _container.createChannelUser(c);
      
      print(u.id);
      sendToClient(c, PacketFactory.get(new ConnectionSuccessPacket.With(u.id)));
      
      Channel chan;
      chan = _channelContainer.findChannel(hp.channelId);
      if (chan != null) {
        if (chan.canJoin) {
          chan.join(u);
        } else {
          c.close(1003, "Channel was full");
          _container.removeUser(u);
          u = null;
          return;
        }
      } else {
        chan = _channelContainer.createChannelWithId(hp.channelId);
        chan.join(u);
      }
    } catch(e) {
      print(e);
    }
  }
  
  void handleBye(ByePacket bp, WebSocketConnection c) {
    ChannelUser user = _container.findUserByConn(c) as ChannelUser;
    
    try {
      if (user != null) {
        user.channel.leave(user);
        _container.removeUser(user);
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
        print("user wass not found");
        return;
      }
      
      um.id = user.id;
      
      sendToClient(other.connection, PacketFactory.get(um));
      
    } on NoSuchMethodError catch(e) {
      print("Somethign was null: $e");
    } catch(e) {
      print(e);
    }
  }
}
