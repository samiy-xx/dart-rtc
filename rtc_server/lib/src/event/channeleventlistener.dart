part of rtc_server;

/**
 * Interface for channel events
 */
abstract class ChannelEventListener {
  
}

/**
 * Interface for channel connection notifications
 */
abstract class ChannelConnectionEventListener extends ChannelEventListener {
  /**
   * User enters channel
   */
  void onEnterChannel(Channel c, User u);
  
  /**
   * User leaves channel
   */
  void onLeaveChannel(Channel c, User u);
}

/**
 * Interface for channel queue notifications
 */
abstract class ChannelQueueEventListener extends ChannelEventListener {
  /**
   * User enters queue
   * count is users in queue
   * position is your position in the queue
   */
  void onEnterQueue(Channel c, User u, int count, int position);
  
  /**
   * User moves in queue
   */
  void onMoveInQueue(Channel c, User u, int count, int position);
  
  /**
   * User leaves queue
   */
  void onLeaveQueue(Channel c, User u);
}

