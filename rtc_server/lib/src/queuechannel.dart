part of rtc_server;

class QueueChannel extends Channel implements UserConnectionEventListener {
  /* Queue users here */
  List<User> _queue;
  
  /**
   * Queue
   */
  List<User> get queue => _queue;
  
  /** Override canJoin from Channel */
  bool get canJoin => true;
  
  /**
   * Set the channel limit to 2
   */
  QueueChannel.With(ChannelContainer rc, String id) : super.With(rc, id, 2){
    _queue = new List<User>();
  }
  
  bool join(User u) {
    //if (super.canJoin) {
    //  return super.join(u);
    //} else {
    if (userCount == 0)
      return super.join(u);
    
    _insertIntoQueue(u);
    u.subscribe(this);
    return false;
    //}
    //return false;
  }
  
  void leave(User u) {
    super.leave(u);
    if (_isInQueue(u))
      _removeFromQueue(u);
    /*User n = _popFromQueue();
    if (n != null) {
      super.join(n);
      n.unsubscribe(this);
    }*/
  }
  
  void next() {
    User n = _popFromQueue();
    if (n != null) {
      super.join(n);
      
    }
  }
  
  bool _isInQueue(User u) {
    return _queue.indexOf(u) > -1;
  }
  
  void _removeFromQueue(User u) {
    int index = _queue.indexOf(u);
    if (index > -1)
      _queue.removeAt(index);
    
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
  }
  
  void _insertIntoQueue(User u) {
    _queue.addLast(u);
    listeners.where((l) => l is ChannelQueueEventListener).forEach((ChannelQueueEventListener l) {
      l.onEnterQueue(this, u, _queue.length, _queue.indexOf(u));
    });
    
  }
  
  User _popFromQueue() {
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

