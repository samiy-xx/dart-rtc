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
  
  PeerManager _manager;
  /* Is peer connection open */
  bool _isOpen = false;
  
  /* are we hosting */
  bool _isHost = false;
  
  /* Wee. logger */
  final Logger log = new Logger();
  
  String _id;
  String _roomId;
  
  String get id => _id;
  String get room => _roomId;
  set id(String value) => _id = value;
  set room(String value) => _roomId = value;
  
  /** Getter returning RtcPeerConnection object */
  RtcPeerConnection get peer => _peer;
  
  /** True if hosting the session */
  bool get isHost => _isHost;
  
  /** returns true if connection is open */
  bool get isOpen => _isOpen;
  
  /** returns current readystate */
  String get state => _peer.readyState;
  
  PeerWrapper(PeerManager pm, RtcPeerConnection p) {
    _peer = p;
    _manager = pm;
    
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
  }
  
  void setRemoteSessionDescription(RtcSessionDescription sdp) {
      log.Debug("Creating remote description ${sdp.type} ${sdp.sdp} ");
      _peer.setRemoteDescription(sdp, _onRemoteDescriptionSuccess, _onRTCError);
      
      if (!isHost)
        addStream(_manager.getVideoManager().getLocalStream());
      
      if (sdp.type == SDP_OFFER)
        _sendAnswer();
      
  }
  
  void _sendOffer() {
    _peer.createOffer(_onOfferSuccess, _onRTCError, null);
  }
  
  void _sendAnswer() {
    _peer.createAnswer(_onAnswerSuccess, _onRTCError, null);
  }
  
  void addStream(MediaStream ms) {
    _peer.addStream(ms);
  }
  
  void _onNegotiationNeeded(Event e) {
    log.Info("onNegotiationNeeded");   
    if (isHost)
      _sendOffer();
  }

  void _onOfferSuccess(RtcSessionDescription sdp) {
    log.Debug("Offer created, sending");
    setSessionDescription(sdp);
    //_signalHandler.send(new DescriptionPacket.With(sdp.sdp, 'offer', _userId, _roomId));
    //_offerSent = true;
  }
  
  void _onAnswerSuccess(RtcSessionDescription sdp) {
    log.Debug("Answer created, sending");
    setSessionDescription(sdp);
    //_signalHandler.send(new DescriptionPacket.With(sdp.sdp, 'answer', _userId, _roomId));
  }
  
  void addRemoteIceCandidate(RtcIceCandidate candidate) {
    
    log.Debug("Receiving remote ICE Candidate ${candidate.candidate}");
    _peer.addIceCandidate(candidate);
  }
  
  void _onIceCandidate(RtcIceCandidateEvent c) {
    if (c.candidate != null) {
      log.Debug("Sending local ICE Candidate ${c.candidate.candidate}");
      ICEPacket ice = new ICEPacket.With(c.candidate.candidate, c.candidate.sdpMid, c.candidate.sdpMLineIndex, id, room);
      _manager.getSignalHandler().send(ice);
    } else {
      log.Warning("Local ICE Candidate was null");
      
    }
  }
  
  void _onIceChange(RtcIceCandidateEvent c) {
    log.Debug("ICE Change ${c.candidate.candidate}");
  }
  
  void _onAddStream(MediaStreamEvent e) {
    _manager.getVideoManager().addRemoteStream(e.stream, id, true);
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
