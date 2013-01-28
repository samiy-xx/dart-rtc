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
  
  /* reliable tcp, unreliable udp */
  bool _isReliable = false;
  
  /** Set reliable */
  set isReliable(bool r) => _isReliable = r;
  
  /**
   * Constructor
   */
  DataPeerWrapper(PeerManager pm, RtcPeerConnection p) : super(pm, p) {
    _peer.onDataChannel.listen(_onNewDataChannelOpen);
  }
  
  void setAsHost(bool value) {
    super.setAsHost(value);
    
    _log.Debug("(datapeerwrapper.dart) Initializing datachannel now");
    initChannel();
  }
  
  void initialize() {
    if (_isHost) {
      _log.Debug("Is Host");
      initChannel();
      _sendOffer();
    }
  }
  
  /**
   * Created the data channel
   * TODO: Whenever these reliable and unreliable are implemented by whomever. fix this.
   */
  void initChannel() {
    _dataChannel = _peer.createDataChannel("somelabelhere", {'reliable': _isReliable});
    _dataChannel.binaryType = "arraybuffer";
    _dataChannel.onClose.listen(onDataChannelClose);
    _dataChannel.onOpen.listen(onDataChannelOpen);
    _dataChannel.onError.listen(onDataChannelError);
    _dataChannel.onMessage.listen(onDataChannelMessage); 
  }
  
  /**
   * Sends a packet trough the data channel
   */
  void send(Packet p, [bool asArrayBuffer]) {
    String packet = PacketFactory.get(p);
    if (?asArrayBuffer) {
      // No clue about this atm. does any browser implement this atm?
      ArrayBuffer buf = BinaryData.createBuffer(p);
      sendData(buf);
    } else {
      _dataChannel.send(packet);
    }
  }
  
  /**
   * Send blob
   */
  void sendBlob(Blob b) {
    _dataChannel.send(b);
  }
  
  void sendData(ArrayBuffer d) {
    ArrayBufferView view = new Uint16Array.fromBuffer(d);
    _dataChannel.send(view);
  }
  /**
   * Callback for when data channel created by the other party comes trough the peer
   */
  void _onNewDataChannelOpen(RtcDataChannelEvent e) {
    _dataChannel = e.channel;
    _dataChannel.onClose.listen(onDataChannelClose);
    _dataChannel.onOpen.listen(onDataChannelOpen);
    _dataChannel.onError.listen(onDataChannelError);
    _dataChannel.onMessage.listen(onDataChannelMessage);
  }
  
  /**
   * Data channel is open and ready for data
   */
  void onDataChannelOpen(Event e) {
    _signalStateChanged();
    _log.Debug("(datapeerwrapper.dart) DataChannelOpen $e");
  }
  
  /**
   * Ugh
   */
  void onDataChannelClose(Event e) {
    _signalStateChanged();
    _log.Debug("(datapeerwrapper.dart) DataChannelClose $e"); 
  }

  /**
   * Message, check if blob, otherwise assume string data
   */
  void onDataChannelMessage(MessageEvent e) {
    if (e.data is Blob) {
      _log.Debug("Received Blob");
      throw new NotImplementedException("Blob is not implemented");
    } else if (e.data is ArrayBuffer || e.data is ArrayBufferView) {
      _log.Debug("Received ArrayBuffer ${e.data.runtimeType.toString()}");
      
      throw new NotImplementedException("ArrayBuffer is not implemented");
    } else {
      _log.Debug("Received Text");
      Packet p = PacketFactory.getPacketFromString(e.data);
      if (p != null) {
        _signalPacketArrived(p);
      }
    }
  }

  /**
   * Error
   */
  void onDataChannelError(RtcDataChannelEvent e) {
    _log.Debug("(datapeerwrapper.dart) DataChannelError $e");
  }
  
  /**
   * Signal listeners that packet has arrived
   */
  void _signalPacketArrived(Packet p) {
    listeners.where((l) => l is PeerDataEventListener).forEach((PeerDataEventListener l) {
      l.onPacket(this, p);
    });
  }
  
  /**
   * signal listeners that channel state has changed
   */
  void _signalStateChanged() {
    if (_dataChannel.readyState != _channelState) {
      listeners.where((l) => l is PeerDataEventListener).forEach((PeerDataEventListener l) {
        l.onChannelStateChanged(this, _dataChannel.readyState);
      });
      _channelState = _dataChannel.readyState;
    }
  }
}
