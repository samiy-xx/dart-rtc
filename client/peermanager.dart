part of rtc_client;

class PeerManager {
  final READYSTATE_CLOSED = "closed";
  final READYSTATE_OPEN = "open";
  final Logger log = new Logger();
  
  SignalHandler _signalHandler;
  VideoManager _videoManager;
  List<PeerWrapper> _peers;
  
  VideoManager get videoManager => getVideoManager();
  
  PeerManager(SignalHandler sh, VideoManager vm) {
    _signalHandler = sh;
    _videoManager = vm;
    _peers = new List<PeerWrapper>();
  }
  
  VideoManager getVideoManager() {
    if (_videoManager == null)
      throw new Exception("VideoManager is null, forgot to set it?");
    return _videoManager;
  }
  
  SignalHandler getSignalHandler() {
    if (_signalHandler == null)
      throw new Exception("SignalHandler is null, forgot to set it?");
    return _signalHandler;
  }
  
  PeerWrapper createPeer() {
    RtcPeerConnection peer = new RtcPeerConnection({'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]});
    PeerWrapper wrapper = new PeerWrapper(this, peer);
    peer.on.addStream.add(onAddStream);
    peer.on.removeStream.add(onRemoveStream);
    peer.on.negotiationNeeded.add(onNegotiationNeeded);
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
  
  void onOfferSuccess(RtcSessionDescription sdp) {
    
  }
  
  void onAnswerSuccess(RtcSessionDescription sdp) {
    
  }
  
  void onIceCandidate(RtcIceCandidateEvent c) {
    
  }
  
  void onIceChange(RtcIceCandidateEvent c) {
    
  }
  
  void onAddStream(MediaStreamEvent e) {
    PeerWrapper wrapper = getWrapperForPeer(e.target);
    getVideoManager().addRemoteStream(e.stream, wrapper.id, true);
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
  
  void onNegotiationNeeded(Event e) {
    
  }
  
  void onRemoveStream(Event e) {
    
  }
  
  void onLocalDescriptionSuccess() {
    
  }
  
  void onRemoteDescriptionSuccess() {
    
  }
  
  void onRTCError(String error) {
    
  }
}
