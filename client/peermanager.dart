part of rtc_client;

class PeerManager {
  static PeerManager _instance;
  final READYSTATE_CLOSED = "closed";
  final READYSTATE_OPEN = "open";
  final Logger log = new Logger();
  bool _dataChannelsEnabled = false;
  LocalMediaStream _ms;
  //SignalHandler _signalHandler;
  //VideoManager _videoManager;
  List<PeerWrapper> _peers;
  List<Object> _listeners;
  //List<PeerMediaEventListenerType> _listenerDynamics;
  
  
  //VideoManager get videoManager => getVideoManager();
  set dataChannelsEnabled(bool value) => _dataChannelsEnabled = value;
  
  factory PeerManager() {
    if (_instance == null)
      _instance = new PeerManager._internal();
    
    return _instance;
  }
  
  PeerManager._internal() {
    //_signalHandler = sh;
    //_videoManager = vm;
    _peers = new List<PeerWrapper>();
    _listeners = new List<Object>();
    //_listenerDynamics = new List<PeerMediaEventListenerType>();
  }
  
  void subscribe(Object listener) {
    if (!_listeners.contains(listener))
      _listeners.add(listener);
    /*
    if (listener is PeerEventListener) {
      
      if (!_listeners.contains(listener))
        _listeners.add(listener);
    } else {
      if (!_listenerDynamics.contains(listener))
        _listenerDynamics.add(listener);
    }*/
  }
  /*
  VideoManager getVideoManager() {
    if (_videoManager == null)
      throw new Exception("VideoManager is null, forgot to set it?");
    return _videoManager;
  }
  
  SignalHandler getSignalHandler() {
    if (_signalHandler == null)
      throw new Exception("SignalHandler is null, forgot to set it?");
    return _signalHandler;
  }*/
  
  void setLocalStream(LocalMediaStream ms) {
    _ms = ms;
    _peers.forEach((PeerWrapper p) {
      p.addStream(ms);
    });
  }
  MediaStream getLocalStream() {
    return _ms;
  }
  
  PeerWrapper createPeer() {
    RtcPeerConnection peer = new RtcPeerConnection({'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]});
    PeerWrapper wrapper = _dataChannelsEnabled ? new DataPeerWrapper(this, peer) : new PeerWrapper(this, peer);
    peer.on.addStream.add(onAddStream);
    peer.on.open.add(onOpen);
    peer.on.stateChange.add(onStateChanged);
    
    _peers.add(wrapper);
    return wrapper;
  }
  
  PeerWrapper getWrapperForPeer(RtcPeerConnection p) {
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper wrapper = _peers[i];
      if (wrapper.peer == p)
        return wrapper;
    }
    return null;
  }
  
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
    _listeners.filter((l) => l is PeerMediaEventListener).forEach((PeerMediaEventListener l) {
      log.Debug("PM: notify class stream available");
      l.onRemoteMediaStreamAvailable(e.stream, wrapper.id, true);
    });
    _listeners.filter((l) => l is PeerMediaEventListenerType).forEach((dyn) {
      log.Debug("PM: notify dynamic stream available");
      dyn(e.stream, wrapper.id, true);
    });
    //_listenerDynamics.forEach((dyn) => dyn(e.stream, wrapper.id, true));
  }
  
  void _sendPacket(String p) {
    _listeners.filter((l) => l is PeerPacketEventListener).forEach((PeerPacketEventListener l) {
      l.onPacketToSend(p);
    });
  }
  
  void closeAll() {
    //_peers.forEach((p) => p.close());
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper p = _peers[i];
      p.close();
    }
  }
  
  void remove(PeerWrapper p) {
    p.close();
  }
  
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
