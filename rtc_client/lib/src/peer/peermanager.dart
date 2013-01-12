part of rtc_client;

/**
 * PeerManager takes care of all peer connections
 */
class PeerManager extends GenericEventTarget<PeerEventListener>{
  /* instance */
  static PeerManager _instance;
  
  /** Closed readystate */
  final READYSTATE_CLOSED = "closed";
  
  /** Open readystate */
  final READYSTATE_OPEN = "open";
  
  final Logger log = new Logger();
  bool _dataChannelsEnabled = false;
  LocalMediaStream _ms;
  List<PeerWrapper> _peers;
  
  StreamConstraints _streamConstraints;
  
  set dataChannelsEnabled(bool value) => _dataChannelsEnabled = value;
  
  /**
   * Factory constructor
   */
  factory PeerManager() {
    if (_instance == null)
      _instance = new PeerManager._internal();
    
    return _instance;
  }
  
  /**
   * Internal constructor
   */
  PeerManager._internal() {
    _peers = new List<PeerWrapper>();
    
    _streamConstraints = new StreamConstraints();
  }
  
  
  void setMaxBitRate(int b) {
    _streamConstraints.bitRate = b;
  }
  
  void setLocalStream(LocalMediaStream ms) {
    _ms = ms;
    _peers.forEach((PeerWrapper p) {
      p.addStream(ms);
    });
  }
  
  MediaStream getLocalStream() {
    return _ms;
  }
  
  /**
   * Creates a new peer and wraps it in PeerWrapper
   */
  PeerWrapper createPeer() {
    PeerConstraints con = new PeerConstraints();
    con.dataChannelEnabled = _dataChannelsEnabled;
    
    print(con.toMap());
    RtcPeerConnection peer = new RtcPeerConnection({'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]}, con.toMap());
    
    
    PeerWrapper wrapper;
    if (_dataChannelsEnabled) {
      wrapper = new DataPeerWrapper(this, peer);
    } else {
      wrapper = new PeerWrapper(this, peer);
    }
    
    peer.on.addStream.add(onAddStream);
    peer.on.open.add(onOpen);
    peer.on.stateChange.add(onStateChanged);
    
    _peers.add(wrapper);
    return wrapper;
  }
  
  /**
   * Gets a wrapper containing peer connection
   */
  PeerWrapper getWrapperForPeer(RtcPeerConnection p) {
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper wrapper = _peers[i];
      if (wrapper.peer == p)
        return wrapper;
    }
    return null;
  }
  
  /**
   * Finds a wrapper by id
   */
  PeerWrapper findWrapper(String id) {
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper wrapper = _peers[i];
      if (wrapper.id == id)
        return wrapper;
    }
    return null;
  }
  
  void onAddStream(MediaStreamEvent e) {
    log.Debug("PM: Adding peer");
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    listeners.filter((l) => l is PeerMediaEventListener).forEach((PeerMediaEventListener l) {
      log.Debug("PM: notify class stream available");
      l.onRemoteMediaStreamAvailable(e.stream, wrapper.id, true);
    });
  }
  
  /**
   * Signal handler should listen for event onPacketToSend so that this actually gets sent
   */
  void _sendPacket(String p) {
    listeners.filter((l) => l is PeerPacketEventListener).forEach((PeerPacketEventListener l) {
      l.onPacketToSend(p);
    });
  }
  
  /**
   * Closes all peer connections
   */
  void closeAll() {
    //_peers.forEach((p) => p.close());
    // TODO: Closing the peer modifies the collection
    // on state change where the peer gets removed from collection
    // avoid foreach
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper p = _peers[i];
      p.close();
    }
  }
  
  /**
   * Removes a single peer wrapper
   * Removed from collection after onStateChanged gets fired
   */
  void remove(PeerWrapper p) {
    p.close();
  }
  
  /**
   * Peer state changed
   */
  void onStateChanged(Event e) {
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    log.Debug("onStateChanged: ${wrapper.peer.readyState}");
    
    if (wrapper.peer.readyState == READYSTATE_CLOSED) {
      wrapper.dispose();
      _peers.removeAt(_peers.indexOf(wrapper));
      log.Debug("Peer removed");
    }
  }
  
  void onOpen(Event e) {
    log.Debug("Peer connection is open");
  }
  
  
}
