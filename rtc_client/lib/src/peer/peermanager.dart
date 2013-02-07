part of rtc_client;

/**
 * PeerManager creates and removes peer connections and assigns media streams to them
 */
class PeerManager extends GenericEventTarget<PeerEventListener> {
  /* instance */
  static PeerManager _instance;
  
  /*
   * Closed readystate
   */
  final READYSTATE_CLOSED = "closed";
  
  /* 
   * Open readystate
   */
  final READYSTATE_OPEN = "open";
  
  final Logger _log = new Logger();
  
  /* 
   * Add local stream to peer connections when created
   */
  bool _setLocalStreamAtStart = false;
  
  /* 
   * Enable or disable datachannels
   */
  bool _dataChannelsEnabled = false;
  
  /* 
   * false = udp, true = tcp
  */
  bool _reliableDataChannels = false;
  
  /* 
   * Local media stream from webcam/microphone
  */
  LocalMediaStream _ms;
  
  /* 
   * Created peerwrapper
   */
  List<PeerWrapper> _peers;
  
  // TODO: dartbug.com 7030
  /* Constraints for the stream */
  StreamConstraints _streamConstraints;
  
  /** Add local stream to peer connections when created */
  set setLocalStreamAtStart(bool v) => _setLocalStreamAtStart = v;

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
    // FIX : after 7030
    //PeerConstraints con = new PeerConstraints();
    //con.dataChannelEnabled = _dataChannelsEnabled;
    
    PeerWrapper wrapper = _createWrapper(
        new RtcPeerConnection(
            {'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]},
            {'optional': [{'RtpDataChannels': true}]}
        )
    );
    
    _add(wrapper);
    return wrapper;
  }
  
  /*
   * Creates a wrapper for peer connection
   * if _dataChannelsEnabled then wrapper will be data wrapper
   */
  PeerWrapper _createWrapper(RtcPeerConnection p) {
    PeerWrapper wrapper;
    if (_dataChannelsEnabled) {
      wrapper = new DataPeerWrapper(this, p);
      (wrapper as DataPeerWrapper).isReliable = _reliableDataChannels;
    } else {
      wrapper = new PeerWrapper(this, p);
    }
    
    if (_setLocalStreamAtStart && _ms != null)
      wrapper.addStream(_ms);
    
    p.onAddStream.listen(onAddStream);
    p.onRemoveStream.listen(onRemoveStream);
    
    //p.onOpen.listen(onOpen);
    p.onStateChange.listen(onStateChanged);
    p.onIceCandidate.listen(onIceCandidate);
    
    listeners.where((l) => l is PeerConnectionEventListener).forEach((PeerConnectionEventListener l) {
      l.onPeerCreated(wrapper);
    });
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
  
  void onIceCandidate(RtcIceCandidateEvent e) {
    if (e.candidate == null) {
      listeners.where((l) => l is PeerConnectionEventListener).forEach((PeerConnectionEventListener l) {
        l.onIceGatheringStateChanged(getWrapperForPeer(e.target), "finished");
      });
    }
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
  
  void _add(PeerWrapper p) {
    if (!_peers.contains(p))
      _peers.add(p);
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
      int index = _peers.indexOf(wrapper);
      if (index >= 0)
        _peers.removeAt(index);
    } else if (wrapper.peer.readyState == READYSTATE_OPEN) {
      onOpen(e);
    }
    
  }
  
  void onOpen(Event e) {
    _log.Debug("Peer connection is open");
  }
  
  
}
