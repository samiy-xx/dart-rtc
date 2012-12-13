part of rtc_client;

/**
 * PeerWrapper
 * Wraps the peer connection comfortably
 */
class PeerWrapper {
  /** Session Description type offer */
  final String SDP_OFFER = 'offer';
  
  /** Session Description type answer */
  final String SDP_ANSWER = 'answer';
  
  /* The connection !! */
  RtcPeerConnection _peer;
  
  /* Is peer connection open */
  bool _isOpen = false;
  
  /* are we hosting */
  bool _isHost = false;
  
  /* Wee. logger */
  final Logger log = new Logger();
  
  /** Getter returning RtcPeerConnection object */
  RtcPeerConnection get peer => _peer;
  
  /** True if hosting the session */
  bool get isHost => _isHost;
  
  /** returns true if connection is open */
  bool get isOpen => _isOpen;
  
  /** returns current readystate */
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
  
  void setSessionDescription(RtcSessionDescription sdp) {
    log.Debug("Creating local description");
    _peer.setLocalDescription(sdp, _onLocalDescriptionSuccess, _onRTCError);
    _localDescriptionSet = true;
  }
  
  void setRemoteSessionDescription(RtcSessionDescription sdp) {
      log.Debug("Creating remote description ${sdp.type} ${sdp.sdp} ");
      _peer.setRemoteDescription(sdp, _onRemoteDescriptionSuccess, _onRTCError);
      
      if (!isHost)
        addLocalStream();
      
      if (sdp.type == SDP_OFFER)
        sendAnswer();
      
  }
  
  void sendOffer() {
    _peer.createOffer(_onOfferSuccess, _onRTCError, null);
  }
  
  void sendAnswer() {
    _peer.createAnswer(_onAnswerSuccess, _onRTCError, null);
  }
  
  void addStream(MediaStream ms) {
    _peer.addStream(ms);
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
  
  void _onLocalDescriptionSuccess() {
    
  }
  
  void _onRemoteDescriptionSuccess() {
    
  }
  
  void _onRTCError(String error) {
    log.Error(error);
  }
  
  void dispose() {
    _peer.close();
    _peer = null;
  }
}
