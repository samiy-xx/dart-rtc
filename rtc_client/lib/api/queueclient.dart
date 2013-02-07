part of rtc_client;

/**
 * QueueClient exposes functionality for queue based video sessions
 */
class QueueClient extends ChannelClient  {
  /* Is the user in queue */
  bool _isInQueue = false;
  
  /* 
   * Currently queued users
   * For a channel owner, this queue contains all users queuing
   * For a user in queue, it contains only the user himself
   */
  List<QueueUser> _queued;
  
  /** Currently queued users */
  List<QueueUser> get queued => _queued;
  
  /* controller for QueueEvents */
  StreamController<QueueEvent> _queueController;
  
  /** Allows to subscribe for queue events */
  Stream<QueueEvent> get onQueueEvent => _queueController.stream;
  
  QueueClient(DataSource ds) : super(ds){
    _queued = new List<QueueUser>();
    _queueController = new StreamController.broadcast();
    _sh.registerHandler(PacketType.QUEUE, _queuePacketHandler);
  }
  
  /**
   * Initializes the connection
   * and clears the queue
   */
  void initialize() {
    super.initialize();
    _queued.clear();
  }
  
  /**
   * Request a new user from queue
   */
  void nextUser() {
    if (isChannelOwner) {
      disconnectUser();
      window.setTimeout(() {
        _sh.send(PacketFactory.get(new NextPacket.With(_myId, _channelId)));
      }, 200);
    }
  }
  
  void _queuePacketHandler(QueuePacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
    
    if (!_queueController.hasSubscribers)
      return;
    
    QueueUser qu = _findQueueUser(p.id);
    if (qu == null) {
      qu = new QueueUser(p.id, int.parse(p.position));
      _addToQueue(qu);
      _queueController.add(new QueueEvent(QueueEventType.ENTER, int.parse(p.position)));
      return;
    }
    qu.position = int.parse(p.position);
    
    //if (!isChannelOwner) {
      if (int.parse(p.position) == 0) {
        _queueController.add(new QueueEvent(QueueEventType.LEAVE, int.parse(p.position)));
        _removeFromQueue(qu);
      } else {
        _queueController.add(new QueueEvent(QueueEventType.MOVE, int.parse(p.position)));
        
      }  
  }
  
  void _addToQueue(QueueUser u) {
    if (!_queued.contains(u))
      _queued.add(u);
  }
  
  void _removeFromQueue(QueueUser u) {
    int idx = _queued.indexOf(u);
    if (idx > -1)
      _queued.removeAt(idx);
  }
  
  QueueUser _findQueueUser(String id) {
    for (int i = 0; i < _queued.length; i++) {
      QueueUser u = _queued[i];
      if (u.id == id)
        return u;
    }
    return null;
  }
}

class QueueUser implements Comparable {
  DateTime entered;
  String id;
  int position;
  
  QueueUser(String i, int p) {
    id = i;
    position = p;
    entered = new DateTime.now();
  }
  
  int compareTo(QueueUser o) {
    if (position < o.position)
      return -1;
    
    if (position == o.position)
      return 0;
    
    return 1;
  }
}

