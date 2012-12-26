part of rtc_client;

class DataPeerWrapper extends PeerWrapper {
  RtcDataChannel _dataChannel;
  Logger _log = new Logger();
  
  DataPeerWrapper(PeerManager pm, RtcPeerConnection p) : super(pm, p){
    _peer.on.iceCandidate.add(_onIceCandidate);
  }
  
  void _onIceCandidate(RtcIceCandidateEvent c) {
    if (c.candidate == null) {
      // Assume done?
      
      _dataChannel = _peer.createDataChannel("1");
      _dataChannel.on.close.add(onDataChannelClose);
      _dataChannel.on.open.add(onDataChannelOpen);
      _dataChannel.on.error.add(onDataChannelError);
      _dataChannel.on.message.add(onDataChannelMessage);
    }
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
  
}