part of rtc_server;

class QueueContainer extends ChannelContainer {
  
  QueueContainer(Server s) : super(s) {
    _channelLimit = 2;
  }
  
  
}

