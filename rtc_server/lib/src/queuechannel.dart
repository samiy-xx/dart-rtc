part of rtc_server;

class QueueChannel extends Channel {
  List<User> _queue;
  
  bool get canJoin => true;
  
  QueueChannel(ChannelContainer rc, String id, int limit) : super(rc, id, 2){
    _queue = new List<User>();
    subscribe(this);
  }
  
  void join(User u) {
    if (super.canJoin) {
      super.join(u);
    } else {
      insertIntoQueue(u);
    }
  }
  
  void leave(User u) {
    super.leave(u);
    
    User n = popFromQueue();
    if (n != null) {
      super.join(n);
    }
  }
  void insertIntoQueue(User u) {
    _queue.addLast(u);
    listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
      l.onEnterQueue(u, _queue.length, _queue.indexOf(u));
    });
  }
  
  User popFromQueue() {
    if (_queue.length == 0)
      return null;
    
    User u = _queue.removeAt(0);
    listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
      l.onLeaveQueue(u);
    });
    
    if (_queue.length > 0) {
      for (int i = 0; i < _queue.length; i++) {
        User qu = _queue[i];
        listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
          l.onMoveInQueue(qu, _queue.length, i);
        });
      }
    }
  }
}

