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
  set isHost(bool value) => setAsHost(value);
  /** returns true if connection is open */
  bool get isOpen => _isOpen;
  
  /** returns current readystate */
  String get state => _peer.readyState;
  
  PeerWrapper(PeerManager pm, RtcPeerConnection p) {
    _peer = p;
    _manager = pm;
    _peer.on.iceCandidate.add(_onIceCandidate);
    _peer.on.iceChange.add(_onIceChange);
    _peer.on.removeStream.add(_onRemoveStream);
    _peer.on.negotiationNeeded.add(_onNegotiationNeeded);
    _peer.on.open.add((Event e) => _isOpen = true);
  }
  
  void setAsHost(bool value) {
    log.Debug("(peerwrapper.dart) Setting as host");
    _isHost = value;
  }
  
  /**
   * Sets the local session description
   * after offer created or replied with answer
   */
  void setSessionDescription(RtcSessionDescription sdp) {
    log.Debug("(peerwrapper.dart) Creating local description");
    _peer.setLocalDescription(sdp, _onLocalDescriptionSuccess, _onRTCError);
  }
  
  /**
   * Remote description comes over datasource
   * if the type is offer, then a answer must be created
   */
  void setRemoteSessionDescription(RtcSessionDescription sdp) {
      log.Debug("(peerwrapper.dart) Setting remote description ${sdp.type}");
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
  
  /*
   * Send the session description created by _sendOffer to the remote party
   * and set is our local session description
   */
  void _onOfferSuccess(RtcSessionDescription sdp) {
    log.Debug("(peerwrapper.dart) Offer created, sending");
    setSessionDescription(sdp);
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'offer', _id, _channelId)));
    //_offerSent = true;
  }
  
  /*
   * Send the session description created by _sendAnswer to the remote party
   * and set it our local session description
   */
  void _onAnswerSuccess(RtcSessionDescription sdp) {
    log.Debug("(peerwrapper.dart) Answer created, sending");
    setSessionDescription(sdp);
    _manager._sendPacket(PacketFactory.get(new DescriptionPacket.With(sdp.sdp, 'answer', _id, _channelId)));
  }
  
  /**
   * Ads a MediaStream to the peer connection
   */
  void addStream(MediaStream ms) {
    if (ms == null)
      throw new Exception("MediaStream was null");
    log.Debug("(peerwrapper.dart) Adding stream to peer $id");
    _peer.addStream(ms, _manager._streamConstraints.toMap());
  }
  
  /*
   * Gets fired whenever there's a change in peer connection
   * ie. when you create a peer connection and add an mediastream there.
   * 
   * Send an offer if isHost property is true
   * means we're hosting and the other party must reply with answer
   */
  void _onNegotiationNeeded(Event e) {
    log.Info("(peerwrapper.dart) onNegotiationNeeded");   
    //initialize();
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
      log.Debug("(peerwrapper.dart) Receiving remote ICE Candidate ${candidate.candidate}");
      _peer.addIceCandidate(candidate);
    }
  }
  
  /*
   * Peer connection generated a ice candidate and this must be delivered to the
   * other party via datasource
   */
  void _onIceCandidate(RtcIceCandidateEvent c) {
    
    if (c.candidate != null) {
      log.Debug("(peerwrapper.dart) (ice gathering state ${_peer.iceGatheringState}) (ice state ${_peer.iceState}) Sending local ICE Candidate ${c.candidate.candidate} ");
      IcePacket ice = new IcePacket.With(c.candidate.candidate, c.candidate.sdpMid, c.candidate.sdpMLineIndex, id);
      _manager._sendPacket(PacketFactory.get(ice));
    } else {
      log.Warning("(peerwrapper.dart) Local ICE Candidate was null  ${_peer.iceState}");
    }
  }
  
  /*
   * Not sure
   */
  void _onIceChange(Event c) {
    log.Debug("(peerwrapper.dart) ICE Change ${c} (ice gathering state ${_peer.iceGatheringState}) (ice state ${_peer.iceState})");
  }
  
  
  void _onRemoveStream(Event e) {
    
  }
  
  void _onLocalDescriptionSuccess() {
    log.Debug("(peerwrapper.dart) Setting local description was success");
  }
  
  void _onRemoteDescriptionSuccess() {
    log.Debug("(peerwrapper.dart) Setting remote description was success");
  }
  
  void _onRTCError(String error) {
    log.Error("(peerwrapper.dart) RTC ERROR : $error");
  }
  
  /**
   * Close the peer connection if not closed already
   */
  void close() {
    log.Error("(peerwrapper.dart) Closing peer");
    if (_peer.readyState != READYSTATE_CLOSED) {
      _peer.close();
      log.Error("(peerwrapper.dart) Peer close called");
    }
  }
  
  /**
   * Dispose
   */
  void dispose() {
    if (_peer.readyState != READYSTATE_CLOSED)
      _peer.close();
    _peer = null;
  }
}
