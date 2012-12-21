part of rtc_client;

class DataPeerWrapper extends PeerWrapper {
  RtcDataChannel _dataChannel;
  Logger _log = new Logger();
  
  DataPeerWrapper(PeerManager pm, RtcPeerConnection p) : super(pm, p){
    _dataChannel = _peer.createDataChannel("1");
    _dataChannel.on.close.add(onDataChannelClose);
    _dataChannel.on.open.add(onDataChannelOpen);
    _dataChannel.on.error.add(onDataChannelError);
    _dataChannel.on.message.add(onDataChannelMessage);
  }
  
  void onDataChannelOpen(RtcDataChannelEvent e) {
    _log.Debug("DataChannelOpen $e");
  }
  
  void onDataChannelClose(RtcDataChannelEvent e) {
    _log.Debug("DataChannelClose $e");
  }

  void onDataChannelMessage(RtcDataChannelEvent e) {
    _log.Debug("DataChannelMessage $e");
  }

  void onDataChannelError(RtcDataChannelEvent e) {
    _log.Debug("DataChannelError $e");
  }
  
}
