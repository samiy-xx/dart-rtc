part of rtc_server;

class QueueChannel extends Channel implements UserConnectionEventListener {
  /* Queue users here */
  List<User> _queue;
  
  /** Override canJoin from Channel */
  bool get canJoin => true;
  
  /**
   * Set the channel limit to 2
   */
  QueueChannel(ChannelContainer rc, String id) : super(rc, id, 2){
    _queue = new List<User>();
  }
  
  /**
   * Implements UserConnectionEventListener
   */
  void onClose(User user, int code, String reason){
    leave(user);
  }
  
  void join(User u) {
    if (super.canJoin) {
      super.join(u);
    } else {
      insertIntoQueue(u);
      u.subscribe(this);
    }
  }
  
  void leave(User u) {
    super.leave(u);
    
    User n = popFromQueue();
    if (n != null) {
      super.join(n);
      n.unsubscribe(this);
    }
  }
  
  void insertIntoQueue(User u) {
    _queue.addLast(u);
    listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
      l.onEnterQueue(this, u, _queue.length, _queue.indexOf(u));
    });
  }
  
  User popFromQueue() {
    if (_queue.length == 0)
      return null;
    
    User u = _queue.removeAt(0);
    listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
      l.onLeaveQueue(this, u);
    });
    
    if (_queue.length > 0) {
      for (int i = 0; i < _queue.length; i++) {
        User qu = _queue[i];
        listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
          l.onMoveInQueue(this, qu, _queue.length, i);
        });
      }
    }
    
    return u;
  }
}

