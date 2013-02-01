part of rtc_client;

class QueueEventType {
  final int _type;
  static final QueueEventType ENTER = const QueueEventType(1);
  static final QueueEventType LEAVE = const QueueEventType(2);
  static final QueueEventType MOVE = const QueueEventType(3);
  const QueueEventType(int t) : _type = t;
}

class QueueEvent extends RtcEvent {
  QueueEventType type;
  int position;
  
  
  QueueEvent(this.type, this.position);  
}

