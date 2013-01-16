part of rtc_server;

abstract class ChannelEventListener {
  
}

abstract class ChannelConnectionEventListener extends ChannelEventListener {
  void onEnterChannel(Channel c, User u);
  void onLeaveChannel(Channel c, User u);
}

abstract class ChannelQueueEventListener extends ChannelEventListener {
  void onEnterQueue(Channel c, User u, int count, int position);
  void onMoveInQueue(Channel c, User u, int count, int position);
  void onLeaveQueue(Channel c, User u);
}

