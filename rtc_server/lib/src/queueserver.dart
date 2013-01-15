part of rtc_server;

class QueueServer extends WebSocketServer implements ContainerContentsEventListener {
  QueueContainer _queueContainer;
  
  QueueServer() : super() {
    registerHandler("helo", handleHelo);
    registerHandler("bye", handleBye);
    registerHandler("peercreated", handlePeerCreated);
    registerHandler("usermessage", handleUserMessage);
    
    _queueContainer = new QueueContainer(this);
    _queueContainer.subscribe(this);
  }
  
  void onEnterQueue(User u, int count, int position) {
    
  }
  void onMoveInQueue(User u, int count, int position) {
    
  }
  void onLeaveQueue(User u) {
    
  }
  void onCountChanged(BaseContainer bc) {
    new Logger().Info("Container count changed ${bc.count}");
    displayStatus();
  }
  
  String displayStatus() {
    new Logger().Info("Users: ${_container.userCount} Channels: ${_queueContainer.channelCount}");
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
      chan = _queueContainer.findChannel(hp.channelId);
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
        chan = _queueContainer.createChannelWithId(hp.channelId);
        chan.join(u);
      }
    } catch(e, s) {
      new Logger().Error(e);
      new Logger().Info(s);
    }
  }
  
}

