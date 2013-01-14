part of rtc_server;

class QueueChannel extends Channel {
  List<User> _queue;
  
  QueueChannel(ChannelContainer rc, String id) : super(rc, id, 2) {
    
  }
  
  void join(ChannelUser u) {
    if (canJoin) {
      super.join(u);
    } else {
      
    }
  }
}

