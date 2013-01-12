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
    initChannel();
  }
  
  void initChannel() {
    _dataChannel = _peer.createDataChannel("somelabelhere", { 'reliable' : false });
    _dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);
  }
  
  void onDataChannelOpen(RtcDataChannelEvent e) {
    _log.Debug("DataChannelOpen $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
    
    _dataChannel.send("I HAS OPENED");
  }
  
  void onDataChannelClose(RtcDataChannelEvent e) {
    _log.Debug("DataChannelClose $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
  }

  void onDataChannelMessage(RtcDataChannelEvent e) {
    
    _log.Debug("DataChannelMessage $e");
    _log.Debug("DataChannel readystate = ${_dataChannel.readyState}");
  }

  void onDataChannelError(RtcDataChannelEvent e) {
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
