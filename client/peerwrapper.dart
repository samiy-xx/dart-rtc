part of rtc_client;

class PeerWrapper {
  RtcPeerConnection _peer;
  RtcPeerConnection get peer => _peer;
  bool _isOpen = false;
  
  bool get isOpen => _isOpen;
  String get state => _peer.readyState;
  
  PeerWrapper(RtcPeerConnection p) {
    _peer = p;
    _peer.on.iceCandidate.add(_onIceCandidate);
    _peer.on.iceChange.add(_onIceChange);
    _peer.on.addStream.add(_onAddStream);
    _peer.on.removeStream.add(_onRemoveStream);
    _peer.on.negotiationNeeded.add(_onNegotiationNeeded);
    _peer.on.open.add((Event e) => _isOpen = true);
  }
  
  void _onNegotiationNeeded(Event e) {
    
  }

  void _onOfferSuccess(RtcSessionDescription sdp) {
    
  }
  
  void _onAnswerSuccess(RtcSessionDescription sdp) {
    
  }
  
  void _onIceCandidate(RtcIceCandidateEvent c) {
    
  }
  
  void _onIceChange(RtcIceCandidateEvent c) {
    
  }
  
  void _onAddStream(MediaStreamEvent e) {
    
  }
  
  void _onRemoveStream(Event e) {
    
  }
  void dispose() {
    _peer.close();
    _peer = null;
  }
}
