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
  DataPeerWrapper(PeerManager pm, RtcPeerConnection p) : super(pm, p) {
    _peer.onOpen.listen(_onOpen);
    _peer.onDataChannel.listen(_onNewDataChannelOpen);
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
    
  void _onOpen(Event e) {
   
  }
  
  void initChannel() {
    window.setTimeout(() {
      _dataChannel = _peer.createDataChannel("somelabelhere", {'reliable': false});
      _log.Debug("(datapeerwrapper.dart) DataChannel created");
      _dataChannel.onClose.listen(onDataChannelClose);
      _dataChannel.onOpen.listen(onDataChannelOpen);
      _dataChannel.onError.listen(onDataChannelError);
      _dataChannel.onMessage.listen(onDataChannelMessage);
      //_dataChannel.binaryType = "blob";
      
    }, 2000);
  }
  
  void _onNewDataChannelOpen(RtcDataChannelEvent e) {
    _dataChannel = e.channel;
   
    _log.Debug("(datapeerwrapper.dart) DataChannel received");
    _log.Debug("(datapeerwrapper.dart) Channel label : ${_dataChannel.label}");
    _log.Debug("(datapeerwrapper.dart) Channel state : ${_dataChannel.readyState}");
    _log.Debug("(datapeerwrapper.dart) Channel reliable : ${_dataChannel.reliable}");
    _dataChannel.onClose.listen(onDataChannelClose);
    _dataChannel.onOpen.listen(onDataChannelOpen);
    _dataChannel.onError.listen(onDataChannelError);
    _dataChannel.onMessage.listen(onDataChannelMessage);
    
    window.setTimeout(() {
      _log.Debug("(datapeerwrapper.dart) DataChannel received");
      _log.Debug("(datapeerwrapper.dart) Channel label : ${_dataChannel.label}");
      _log.Debug("(datapeerwrapper.dart) Channel state : ${_dataChannel.readyState}");
      _log.Debug("(datapeerwrapper.dart) Channel reliable : ${_dataChannel.reliable}");
    }, 1000);
  }
  
  void onDataChannelOpen(Event e) {
    _signalStateChanged();
    _log.Debug("(datapeerwrapper.dart) DataChannelOpen $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
    
    _dataChannel.send("I HAS OPENED");
  }
  
  void onDataChannelClose(Event e) {
    _signalStateChanged();
    _log.Debug("(datapeerwrapper.dart) DataChannelClose $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
  }

  void onDataChannelMessage(MessageEvent e) {
    
    _log.Debug("(datapeerwrapper.dart) DataChannelMessage ${e.data}");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
    
  }

  void onDataChannelError(RtcDataChannelEvent e) {
    _log.Debug("(datapeerwrapper.dart) DataChannelError $e");
    _log.Debug("(datapeerwrapper.dart) DataChannel readystate = ${_dataChannel.readyState}");
  }
 
  void _signalStateChanged() {
    if (_dataChannel.readyState != _channelState) {
      
      listeners.where((l) => l is PeerDataEventListener).forEach((PeerDataEventListener l) {
        l.onChannelStateChanged(this, _dataChannel.readyState);
      });
      _channelState = _dataChannel.readyState;
    }
  }
}
