part of rtc_client;

/**
 * DataChannel enabled peer connection
 */
class DataPeerWrapper extends PeerWrapper {
  /* DataChannel */
  RtcDataChannel _dataChannel;
  
  /* Logger */
  Logger _log = new Logger();
  
  /* Current channel state */
  String _channelState = null;
  
  /**
   * Constructor
   */
  DataPeerWrapper(PeerManager pm, RtcPeerConnection p) : super(pm, p){
    _peer.on.iceCandidate.add(_onIceCandidate);
    _peer.on.open.add(_onOpen);
    _peer.on['datachannel'].add(_onNewDataChannelOpen);
  }
  
  void setAsHost(bool value) {
    super.setAsHost(value);
    
    _log.Debug("(datapeerwrapper.dart) Initializing datachannel now");
    initChannel();
  }
  
  void initialize() {
    //super.initialize();
    if (_isHost) {
      log.Debug("Is Host");
      initChannel();
      _sendOffer();
    }
    //super.initialize();
    
    
  }
  /*
   * When receiving null ice candidate, assume connection established
   * create datachannel
   */
  void _onIceCandidate(RtcIceCandidateEvent c) {
    if (c.candidate == null) {
      // Assume done?
    }
  }
  
  void _onOpen(Event e) {
   
  }
  
  void initChannel() {
    _dataChannel = _peer.createDataChannel("somelabelhere", { 'reliable' : false });
    _log.Debug("(datapeerwrapper.dart) DataChannel created");
    _dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);
    
    
  }
  
  void _onNewDataChannelOpen(RtcDataChannelEvent e) {
    _dataChannel = e.channel;
   
    _log.Debug("(datapeerwrapper.dart) DataChannel received");
    _log.Debug("(datapeerwrapper.dart) Channel label : ${_dataChannel.label}");
    _log.Debug("(datapeerwrapper.dart) Channel state : ${_dataChannel.readyState}");
    _log.Debug("(datapeerwrapper.dart) Channel reliable : ${_dataChannel.reliable}");
    _dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);
  }
  
  void onDataChannelOpen(Event e) {
    
    _log.Debug("(datapeerwrapper.dart) DataChannelOpen $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
    
    _dataChannel.send("I HAS OPENED");
  }
  
  void onDataChannelClose(Event e) {
    _log.Debug("(datapeerwrapper.dart) DataChannelClose $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
  }

  void onDataChannelMessage(Event e) {
    
    _log.Debug("(datapeerwrapper.dart) DataChannelMessage $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
    
  }

  void onDataChannelError(Event e) {
    _log.Debug("(datapeerwrapper.dart) DataChannelError $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
  }
 
  void _signalStateChanged() {
    if (_dataChannel.readyState != _channelState) {
      
      listeners.filter((l) => l is PeerDataEventListener).forEach((PeerDataEventListener l) {
        l.onChannelStateChanged(this, _dataChannel.readyState);
      });
      _channelState = _dataChannel.readyState;
    }
  }
}
