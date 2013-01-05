part of rtc_client;

/**
 * PeerWrapper
 * Wraps the peer connection comfortably
 */
class PeerWrapper {
  
  final READYSTATE_CLOSED = "closed";
  final READYSTATE_OPEN = "open";
  
  /** Session Description type offer */
  final String SDP_OFFER = 'offer';
  
  /** Session Description type answer */
  final String SDP_ANSWER = 'answer';
  
  RtcDataChannel _dataChannel;
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
  String _channelId;
  
  String get id => _id;
  String get channel => _channelId;
  set id(String value) => _id = value;
  set channel(String value) => _channelId = value;
  
  /** Getter returning RtcPeerConnection object */
  RtcPeerConnection get peer => _peer;
  
  /** True if hosting the session */
  bool get isHost => _isHost;
  
  /** returns true if connection is open */
  bool get isOpen => _isOpen;
  
  /** returns current readystate */
  String get state => _peer.readyState;
  
  List<PeerEventListener> _listeners;
  
  PeerWrapper(PeerManager pm, RtcPeerConnection p) {
    _peer = p;
    _manager = pm;
    _listeners = new List<PeerEventListener>();
    _peer.on.iceCandidate.add(_onIceCandidate);
    _peer.on.iceChange.add(_onIceChange);
    _peer.on.removeStream.add(_onRemoveStream);
    _peer.on.negotiationNeeded.add(_onNegotiationNeeded);
    _peer.on.open.add((Event e) => _isOpen = true);
    
    //_Datachannel = _peer.createDataChannel("1");
    //_channel.on.message.add(listener, useCapture)
  }
  
  void subscribe(PeerEventListener listener) {
    if (!_listeners.contains(listener))
      _listeners.add(listener);
  }
  
  void setSessionDescription(RtcSessionDescription sdp) {
    log.Debug("Creating local description");
    _peer.setLocalDescription(sdp, _onLocalDescriptionSuccess, _onRTCError);
  }
  
  void setRemoteSessionDescription(RtcSessionDescription sdp) {
      log.Debug("Creating remote description ${sdp.type} ${sdp.sdp} ");
      _peer.setRemoteDescription(sdp, _onRemoteDescriptionSuccess, _onRTCError);
      
      /*if (!isHost) {
        MediaStream ms = _manager.getVideoManager().getLocalStream();
        if (ms != null)
        addStream(ms);
      }*/
      if (sdp.type == SDP_OFFER)
        _sendAnswer();
      
  }
  void initialize() {
    if (isHost)
      _sendOffer();
    
  }
  
  void _sendOffer() {
    _peer.createOffer(_onOfferSuccess, _onRTCError, null);
  }
  
  void _sendAnswer() {
    _peer.createAnswer(_onAnswerSuccess, _onRTCError, null);
  }
  
  void addStream(MediaStream ms) {
    if (ms == null)
      throw new Exception("MediaStream was null");
    log.Debug("Adding stream to peer $id");
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
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'offer', _id, _channelId)));
    //_offerSent = true;
  }
  
  void _onAnswerSuccess(RtcSessionDescription sdp) {
    log.Debug("Answer created, sending");
    setSessionDescription(sdp);
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'answer', _id, _channelId)));
  }
  
  void addRemoteIceCandidate(RtcIceCandidate candidate) {
    if (candidate == null)
      throw new Exception("RtcIceCandidate was null");
    
    log.Debug("Receiving remote ICE Candidate ${candidate.candidate}");
    _peer.addIceCandidate(candidate);
  }
  
  void _onIceCandidate(RtcIceCandidateEvent c) {
    if (c.candidate != null) {
      log.Debug("Sending local ICE Candidate ${c.candidate.candidate}");
      ICEPacket ice = new ICEPacket.With(c.candidate.candidate, c.candidate.sdpMid, c.candidate.sdpMLineIndex, id, channel);
      _manager._sendPacket(PacketFactory.get(ice));
    } else {
      log.Warning("Local ICE Candidate was null");
      
    }
  }
  
  void _onIceChange(RtcIceCandidateEvent c) {
    log.Debug("ICE Change ${c.candidate.candidate}");
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
  
  void close() {
    if (_peer.readyState != READYSTATE_CLOSED)
      _peer.close();  
  }
  
  void dispose() {
    if (_peer.readyState != READYSTATE_CLOSED)
      _peer.close();
    _peer = null;
  }
}
