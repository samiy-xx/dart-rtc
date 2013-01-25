part of rtc_server_tests;

typedef void onChannelJoinCallback(Channel c, User u);
typedef void onChannelLeaveCallback(Channel c, User u);
typedef void onEnterQueueCallback(Channel c, User u, int count, int pos);
typedef void onMoveInQueueCallback(Channel c, User u, int count, int pos);
typedef void onLeaveQueueCallback(Channel c, User u);

class MockChannelEventListener implements ChannelConnectionEventListener, ChannelQueueEventListener {
  onChannelJoinCallback _joinCallback;
  onChannelLeaveCallback _leaveCallback;
  onEnterQueueCallback _enterQueueCallback;
  onMoveInQueueCallback _moveInQueueCallback;
  onLeaveQueueCallback _leaveQueueCallback;
  
  set joinCallback(onChannelJoinCallback f) => _joinCallback = f;
  set leaveCallback(onChannelLeaveCallback f) => _leaveCallback = f;
  set enterQueueCallback(onEnterQueueCallback f) => _enterQueueCallback = f;
  set moveInQueueCallback(onMoveInQueueCallback f) => _moveInQueueCallback = f;
  set leaveQueueCallback(onLeaveQueueCallback f) => _leaveQueueCallback = f;
  
  void onEnterChannel(Channel c, User u) {
    if (_joinCallback != null)
      _joinCallback(c, u);
  }
  
  void onLeaveChannel(Channel c, User u) {
    if (_leaveCallback != null)
      _leaveCallback(c, u);
  }
  
  void onEnterQueue(Channel c, User u, int count, int position) {
    if (_enterQueueCallback != null)
      _enterQueueCallback(c, u, count, position);
  }
  
  void onMoveInQueue(Channel c, User u, int count, int position) {
    if (_moveInQueueCallback != null)
      _moveInQueueCallback(c, u, count, position); 
  }
  
  void onLeaveQueue(Channel c, User u) {
    if (_leaveQueueCallback != null)
      _leaveQueueCallback(c, u);
  }
}

