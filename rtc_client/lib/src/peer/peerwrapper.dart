part of rtc_client;

/**
 * PeerWrapper
 * Wraps the peer connection comfortably
 */
class PeerWrapper extends GenericEventTarget<PeerEventListener>{
  
  final READYSTATE_CLOSED = "closed";
  final READYSTATE_OPEN = "open";
  
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
  final Logger _log = new Logger();
  
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
  set isHost(bool value) => setAsHost(value);
  /** returns true if connection is open */
  bool get isOpen => _isOpen;
  
  /** returns current readystate */
  String get state => _peer.readyState;
  
  PeerWrapper(PeerManager pm, RtcPeerConnection p) {
    _peer = p;
    _manager = pm;
    _peer.onIceCandidate.listen(_onIceCandidate);
    _peer.onIceChange.listen(_onIceChange);
    _peer.onNegotiationNeeded.listen(_onNegotiationNeeded);
    //_peer.onOpen.listen((Event e) => _isOpen = true);
    _peer.onStateChange.listen(_onStateChange);
  }
  
  void setAsHost(bool value) {
    _log.Debug("(peerwrapper.dart) Setting as host");
    _isHost = value;
  }
  
  /**
   * Sets the local session description
   * after offer created or replied with answer
   */
  void setSessionDescription(RtcSessionDescription sdp) {
    _log.Debug("(peerwrapper.dart) Creating local description");
    _peer.setLocalDescription(sdp, _onLocalDescriptionSuccess, _onRTCError);
  }
  
  /**
   * Remote description comes over datasource
   * if the type is offer, then a answer must be created
   */
  void setRemoteSessionDescription(RtcSessionDescription sdp) {
      _log.Debug("(peerwrapper.dart) Setting remote description ${sdp.type}");
      _peer.setRemoteDescription(sdp, _onRemoteDescriptionSuccess, _onRTCError);
      
      if (sdp.type == SDP_OFFER)
        _sendAnswer();
  }
  
  /**
   * Can be used to initialize connection if not wanting to add mediastream right away
   */
  void initialize() {
    if (isHost)
      _sendOffer();
  }
  
  /*
   * Creates offer and calls callback 
   */
  void _sendOffer() {
    _peer.createOffer(_onOfferSuccess, _onRTCError, null);
  }
  
  /*
   * Answer for offer
   */
  void _sendAnswer() {
    _peer.createAnswer(_onAnswerSuccess, _onRTCError, null);
  }
  
  void _onStateChange(Event e) {
    if (_peer.readyState == READYSTATE_OPEN)
      _isOpen = true;
    else
      _isOpen = false;
  }
  /*
   * Send the session description created by _sendOffer to the remote party
   * and set is our local session description
   */
  void _onOfferSuccess(RtcSessionDescription sdp) {
    _log.Debug("(peerwrapper.dart) Offer created, sending");
    setSessionDescription(sdp);
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'offer', _id, _channelId)));
    //_offerSent = true;
  }
  
  /*
   * Send the session description created by _sendAnswer to the remote party
   * and set it our local session description
   */
  void _onAnswerSuccess(RtcSessionDescription sdp) {
    _log.Debug("(peerwrapper.dart) Answer created, sending");
    setSessionDescription(sdp);
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'answer', _id, _channelId)));
  }
  
  /**
   * Ads a MediaStream to the peer connection
   * TODO: Reintroduce constraints when these compile to javascript properly
   */
  void addStream(MediaStream ms) {
    if (ms == null)
      throw new Exception("MediaStream was null");
    _log.Debug("(peerwrapper.dart) Adding stream to peer $id");
    _peer.addStream(ms);
  }
  
  /*
   * Gets fired whenever there's a change in peer connection
   * ie. when you create a peer connection and add an mediastream there.
   * 
   * Send an offer if isHost property is true
   * means we're hosting and the other party must reply with answer
   */
  void _onNegotiationNeeded(Event e) {
    _log.Info("(peerwrapper.dart) onNegotiationNeeded");   
    
    if (isHost)
      _sendOffer();
  }

  /**
   * These you get from datasource
   * at the moment, a null RtcIceCandidate means that connection is done(tm) =P
   */
  void addRemoteIceCandidate(RtcIceCandidate candidate) {
    if (candidate == null)
      throw new Exception("RtcIceCandidate was null");
    
    if (_peer.readyState != READYSTATE_CLOSED) {
      _log.Debug("(peerwrapper.dart) Receiving remote ICE Candidate ${candidate.candidate}");
      _peer.addIceCandidate(candidate);
    }
  }
  
  /*
   * Peer connection generated a ice candidate and this must be delivered to the
   * other party via datasource
   */
  void _onIceCandidate(RtcIceCandidateEvent c) {
    
    if (c.candidate != null) {
      //_log.Debug("(peerwrapper.dart) (ice gathering state ${_peer.iceGatheringState}) (ice state ${_peer.iceState}) Sending local ICE Candidate ${c.candidate.candidate} ");
      IcePacket ice = new IcePacket.With(c.candidate.candidate, c.candidate.sdpMid, c.candidate.sdpMLineIndex, id);
      _manager._sendPacket(PacketFactory.get(ice));
    } else {
      //_log.Warning("(peerwrapper.dart) Null Ice Candidate, gathering complete");
    }
  }
  
  /*
   * Not sure
   */
  void _onIceChange(Event c) {
    _log.Debug("(peerwrapper.dart) ICE Change ${c} (ice gathering state ${_peer.iceGatheringState}) (ice state ${_peer.iceConnectionState})");
  }
  
  void _onLocalDescriptionSuccess() {
    _log.Debug("(peerwrapper.dart) Setting local description was success");
  }
  
  void _onRemoteDescriptionSuccess() {
    _log.Debug("(peerwrapper.dart) Setting remote description was success");
  }
  
  void _onRTCError(String error) {
    _log.Error("(peerwrapper.dart) RTC ERROR : $error");
  }
  
  /**
   * Close the peer connection if not closed already
   */
  void close() {
    _log.Error("(peerwrapper.dart) Closing peer");
    if (_peer.readyState != READYSTATE_CLOSED)
      _peer.close();   
  }
}
