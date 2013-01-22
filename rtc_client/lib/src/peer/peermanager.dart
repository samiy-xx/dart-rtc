part of rtc_client;

/**
 * PeerManager takes care of all peer connections
 */
class PeerManager extends GenericEventTarget<PeerEventListener> {
  /* instance */
  static PeerManager _instance;
  
  final Logger _log = new Logger();
  
  /* Enable or disable datachannels */
  bool _dataChannelsEnabled = false;
  
  /* false = udp, true = tcp */
  bool _reliableDataChannels = false;
  
  // TODO: Is this the right place for this?
  /* Local media stream from webcam/microphone */
  LocalMediaStream _ms;
  
  /* Created peerwrappers */
  List<PeerWrapper> _peers;
  
  // TODO: dartbug.com 7030
  /* Constraints for the stream */
  StreamConstraints _streamConstraints;
  
  /** Closed readystate */
  final READYSTATE_CLOSED = "closed";
  
  /** Open readystate */
  final READYSTATE_OPEN = "open";
  
  /**
   * Sets the local media stream
   */
  set localMediaStream(LocalMediaStream lms) => setLocalStream(lms);
  
  /**
   * Returns the local media stream
   */
  LocalMediaStream get localMediaStream => getLocalStream();
  
  /** 
   * Set data channels enabled or disabled for all peers created
   */
  set dataChannelsEnabled(bool value) => _dataChannelsEnabled = value;
  
  /**
   * Set data channels reliable = tcp or unreliable = udp
   */
  set reliableDataChannels(bool value) => _reliableDataChannels = value;
  
  /**
   * singleton constructor
   */
  factory PeerManager() {
    if (_instance == null)
      _instance = new PeerManager._internal();
    
    return _instance;
  }
  
  /*
   * Internal constructor
   */
  PeerManager._internal() {
    _peers = new List<PeerWrapper>();
    _streamConstraints = new StreamConstraints();
  }
  
  /**
   * Convenience method
   * Sets the max bit rate to stream constraints
   */
  void setMaxBitRate(int b) {
    _streamConstraints.bitRate = b;
  }
  
  /**
   * Sets the local media stream from users webcam/microphone to all peers
   */
  void setLocalStream(LocalMediaStream ms) {
    _ms = ms;
    _peers.forEach((PeerWrapper p) {
      p.addStream(ms);
    });
  }
  
  /**
   * Returns the current local media stream
   */
  MediaStream getLocalStream() {
    return _ms;
  }
  
  /**
   * Creates a new peer and wraps it in PeerWrapper
   */
  PeerWrapper createPeer() {
    PeerConstraints con = new PeerConstraints();
    con.dataChannelEnabled = _dataChannelsEnabled;
    
    // TODO: after 7030 is fixed, look into using constraints.
    // before that, too much trouble finding what to fix in generated js code
    RtcPeerConnection peer = new RtcPeerConnection({
      'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]}, {'optional': [{'RtpDataChannels': true}]});
    
    PeerWrapper wrapper;
    if (_dataChannelsEnabled) {
      wrapper = new DataPeerWrapper(this, peer);
      (wrapper as DataPeerWrapper).isReliable = _reliableDataChannels;
    } else {
      wrapper = new PeerWrapper(this, peer);
    }
    
    peer.onAddStream.listen(onAddStream);
    peer.onRemoveStream.listen(onRemoveStream);
    peer.onOpen.listen(onOpen);
    peer.onStateChange.listen(onStateChanged);
    
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
  
  /**
   * Callback for mediastream removed
   * Notifies listeners that stream was removed from peer
   */
  void onRemoveStream(MediaStreamEvent e) {
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    
    listeners.where((l) => l is PeerMediaEventListener).forEach((PeerMediaEventListener l) {
      l.onRemoteMediaStreamRemoved(wrapper);
    });
  }
  
  /**
   * Callback for when a media stream is added to peer
   * Notifies listeners that a media stream was added
   */
  void onAddStream(MediaStreamEvent e) {
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    
    listeners.where((l) => l is PeerMediaEventListener).forEach((PeerMediaEventListener l) {
      l.onRemoteMediaStreamAvailable(e.stream, wrapper, true);
    });
  }
  
  /**
   * Signal handler should listen for event onPacketToSend so that this actually gets sent
   */
  void _sendPacket(String p) {
    listeners.where((l) => l is PeerPacketEventListener).forEach((PeerPacketEventListener l) {
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
   * Notifies listeners about the state change
   * If readystate changed to closed, remove the peer wrapper and containing peer
   */
  void onStateChanged(Event e) {
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    _log.Debug("(peermanager.dart) onStateChanged: ${wrapper.peer.readyState}");
    
    listeners.where((l) => l is PeerConnectionEventListener).forEach((PeerConnectionEventListener l) {
      l.onPeerStateChanged(wrapper, wrapper.peer.readyState);
    });
    
    if (wrapper.peer.readyState == READYSTATE_CLOSED) {
      wrapper.dispose();
      
      int index = _peers.indexOf(wrapper);
      if (index >= 0)
        _peers.removeAt(index);
    }
  }
  
  void onOpen(Event e) {
    _log.Debug("Peer connection is open");
  }
  
  
}
