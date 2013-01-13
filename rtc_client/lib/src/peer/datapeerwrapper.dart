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
    
    _log.Debug("Initializing datachannel now");
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
    _log.Debug("DataChannel created");
    /*_dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);*/
    
    _dataChannel.on.open.add((e) {
      _log.Debug("DC OPEN: $e");
    });
    _dataChannel.on.close.add((e) {
      _log.Debug("DC CLOSE: $e");
    });
    _dataChannel.on.error.add((e) {
      _log.Debug("DC ERROR: $e");
    });
    _dataChannel.on.message.add((e) {
      _log.Debug("DC MESSAGE: $e");
    });
  }
  
  void _onNewDataChannelOpen(RtcDataChannelEvent e) {
    _dataChannel = e.channel;
   
    _log.Debug("DataChannel received");
    _log.Debug("Channel label : ${_dataChannel.label}");
    _log.Debug("Channel state : ${_dataChannel.readyState}");
    _log.Debug("Channel reliable : ${_dataChannel.reliable}");
    _dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);
  }
  
  void onDataChannelOpen(Event e) {
    
    _log.Debug("DataChannelOpen $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
    
    _dataChannel.send("I HAS OPENED");
  }
  
  void onDataChannelClose(Event e) {
    _log.Debug("DataChannelClose $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
  }

  void onDataChannelMessage(Event e) {
    
    _log.Debug("DataChannelMessage $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
    
  }

  void onDataChannelError(Event e) {
    _log.Debug("DataChannelError $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
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
