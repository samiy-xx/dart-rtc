part of rtc_client;

class PeerManager {
  final READYSTATE_CLOSED = "closed";
  final READYSTATE_OPEN = "open";
  final Logger log = new Logger();
  
  List<PeerWrapper> _peers;
   
  PeerManager() {
    _peers = new List<PeerWrapper>();
  }
  
  RtcPeerConnection createPeer() {
    RtcPeerConnection peer = new RtcPeerConnection({'iceServers': [ {'url':'stun:stun.l.google.com:19302'}]});
    PeerWrapper wrapper = new PeerWrapper(peer);
    peer.on.iceCandidate.add(onIceCandidate);
    peer.on.iceChange.add(onIceChange);
    peer.on.addStream.add(onAddStream);
    peer.on.removeStream.add(onRemoveStream);
    peer.on.negotiationNeeded.add(onNegotiationNeeded);
    peer.on.open.add(onOpen);
    peer.on.stateChange.add(onStateChanged);
    
    _peers.add(wrapper);
    return peer;
  }
  
  PeerWrapper getWrapperForPeer(RtcPeerConnection p) {
    for (int i = 0; i < _peers.length; i++) {
      PeerWrapper wrapper = _peers[i];
      if (wrapper.peer == p)
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
