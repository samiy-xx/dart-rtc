part of rtc_client;

class ChannelClient implements RtcClient, DataSourceConnectionEventListener,
  PeerConnectionEventListener, PeerMediaEventListener, PeerDataEventListener {
  
  StreamingSignalHandler _sh;
  PeerManager _pm;
  DataSource _ds;
  
  bool _requireAudio = false;
  bool _requireVideo = false;
  bool _requireDataChannel = false;
  
  LocalMediaStream _ms = null;
  
  String _channelId;
  String _myId;
  String _otherId;
  
  /**
   * Signal handler
   */
  StreamingSignalHandler get signalHandler => _sh;
  
  /**
   * PeerManager
   */
  PeerManager get peerManager => _pm;
  
  /**
   * My id
   */
  String get myId => _myId;
  
  /**
   * Are you a channel owner
   */
  bool get isChannelOwner => _sh.isChannelOwner;
  
  StreamController<MediaStreamAvailableEvent> _mediaStreamAvailableStreamController;
  Stream<MediaStreamAvailableEvent> get onRemoteMediaStreamAvailableEvent  => _mediaStreamAvailableStreamController.stream;
  
  StreamController<MediaStreamRemovedEvent> _mediaStreamRemovedStreamController;
  Stream<MediaStreamRemovedEvent> get onRemoteMediaStreamRemovedEvent  => _mediaStreamRemovedStreamController.stream;
  
  StreamController<InitializedEvent> _initializedController;
  Stream<InitializedEvent> get onInitializedEvent => _initializedController.stream;
  
  StreamController<SignalingOpenEvent> _signalingOpenController;
  Stream<SignalingOpenEvent> get onSignalingOpenEvent => _signalingOpenController.stream;
  
  StreamController<SignalingCloseEvent> _signalingCloseController;
  Stream<SignalingCloseEvent> get onSignalingCloseEvent => _signalingCloseController.stream;
  
  StreamController<SignalingErrorEvent> _signalingErrorController;
  Stream<SignalingErrorEvent> get onSignalingErrorEvent => _signalingErrorController.stream;
  
  StreamController<PeerStateChangedEvent> _peerStateChangeController;
  Stream<PeerStateChangedEvent> get onPeerStateChangeEvent => _peerStateChangeController.stream;
  
  StreamController<IceGatheringStateChangedEvent> _iceGatheringStateChangeController;
  Stream<IceGatheringStateChangedEvent> get onIceGatheringStateChangeEvent => _iceGatheringStateChangeController.stream;
  
  StreamController<DataSourceMessageEvent> _dataSourceMessageController;
  Stream<DataSourceMessageEvent> get onDataSourceMessageEvent => _dataSourceMessageController.stream;
  
  StreamController<DataSourceCloseEvent> _dataSourceCloseController;
  Stream<DataSourceCloseEvent> get onDataSourceCloseEvent => _dataSourceCloseController.stream;
  
  StreamController<DataSourceOpenEvent> _dataSourceOpenController;
  Stream<DataSourceOpenEvent> get onDataSourceOpenEvent => _dataSourceOpenController.stream;
  
  StreamController<DataSourceErrorEvent> _dataSourceErrorController;
  Stream<DataSourceErrorEvent> get onDataSourceErrorEvent => _dataSourceErrorController.stream;
  
  StreamController<PacketEvent> _packetController;
  Stream<PacketEvent> get onPacketEvent => _packetController.stream;
  
  ChannelClient(DataSource ds) {
    _ds = ds;
    _ds.subscribe(this);
    
    _pm = new PeerManager();
    _pm.subscribe(this);
    
    _sh = new StreamingSignalHandler(ds);
    
    _initializedController = new StreamController<InitializedEvent>.broadcast();
    _mediaStreamAvailableStreamController = new StreamController.broadcast();
    _mediaStreamRemovedStreamController = new StreamController.broadcast();
    _signalingOpenController = new StreamController.broadcast();
    _signalingCloseController = new StreamController.broadcast();
    _signalingErrorController = new StreamController.broadcast();
    _peerStateChangeController = new StreamController.broadcast();
    _iceGatheringStateChangeController = new StreamController.broadcast();
    _dataSourceMessageController = new StreamController.broadcast();
    _dataSourceCloseController = new StreamController.broadcast();
    _dataSourceOpenController = new StreamController.broadcast();
    _dataSourceErrorController = new StreamController.broadcast();
    _packetController = new StreamController.broadcast();
    
    _sh.registerHandler(PacketType.JOIN, _joinPacketHandler);
    _sh.registerHandler(PacketType.ID, _idPacketHandler);
    _sh.registerHandler(PacketType.BYE, _byePacketHandler);
    _sh.registerHandler(PacketType.CHANNEL, _channelPacketHandler);
    _sh.registerHandler(PacketType.CONNECTED, _connectionSuccessPacketHandler);
    _sh.registerHandler(PacketType.CHANNELMESSAGE, _channelMessagePacketHandler);
  }
  
  void initialize() {
    if (_channelId == null)
      throw new Exception("Channel can not be null, initialize with setChannel");
    
    if (!_requireAudio && !_requireVideo && !_requireDataChannel)
      throw new Exception("Must require either video, audio or data channel");
    
    // If either is set, need to request permission for audio and/or video
    if ((_requireAudio || _requireVideo) && _ms == null) { 
      if (MediaStream.supported) {
        window.navigator.getUserMedia(audio: _requireAudio, video: _requireVideo).then((LocalMediaStream stream) {
          _ms = stream;
          _pm.setLocalStream(stream);
          _sh.initialize();
          _initializedController.add(new InitializedEvent(true, "UserMedia received"));
          _mediaStreamAvailableStreamController.add(new MediaStreamAvailableEvent(stream, null));
        });
      } else {
        _initializedController.add(new InitializedEvent(false, "Failed to get user media"));
        return;
      }
    }
    _sh.initialize();
  }
  
  /**
   * Implements RtcClient setRequireAudio
   */
  ChannelClient setRequireAudio(bool b) {
    _requireAudio = b;
    return this;
  }
  
  /**
   * Implements RtcClient setRequireVideo
   */
  ChannelClient setRequireVideo(bool b) {
    _requireVideo = b;
    return this;
  }
  
  /**
   * Implements RtcClient setRequireDataChannel
   */
  ChannelClient setRequireDataChannel(bool b) {
    _requireDataChannel = b;
    _sh.setDataChannelsEnabled(b);
    return this;
  }
  
  /**
   * Implements RtcClient setChannel
   */
  ChannelClient setChannel(String c) {
    _channelId = c;
    _sh.channelId = c;
    return this;
  }
  
  /**
   * Requests the server to transmit the message to all users in channel
   */
  void sendChannelMessage(String message) {
    _sh.send(PacketFactory.get(new ChannelMessage.With(_myId, _channelId, message)));
  }
  
  /**
   * Sends a message to a peer
   */
  void sendPeerUserMessage(String peerId, String message) {
    sendPeerPacket(peerId, new UserMessage.With(_myId, message));
  }
  
  /**
   * Sends a packet to peer
   */
  void sendPeerPacket(String peerId, Packet p) {
    PeerWrapper w = _pm.findWrapper(peerId);
    if (w is DataPeerWrapper) {
      DataPeerWrapper dpw = w as DataPeerWrapper;
      dpw.send(p);
    }
  }
  
  /**
   * Sends a blob to peer
   */
  void sendBlob(String peerId, Blob data) {
    throw new UnsupportedError("sendBlob is a work in progress");
  }
  
  /**
   * Sends an arraybuffer to peer
   */
  void sendArrayBuffer(String peerId, ArrayBuffer data) {
    throw new UnsupportedError("sendArrayBuffer is a work in progress");
  }
  
  /**
   * Sends an arraybufferview to peer
   */
  void sendArrayBufferView(String peerId, ArrayBufferView data) {
    throw new UnsupportedError("sendArrayBufferView is a work in progress");
  }

  /**
   * Request the server that users gets kicked out of channel
   */
  void disconnectUser() {
    if (isChannelOwner && _otherId != null) {
      _sh.send(PacketFactory.get(new RemoveUserCommand.With(_otherId, _channelId)));
    }
  }
  
  void _channelMessagePacketHandler(ChannelMessage p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void _connectionSuccessPacketHandler(ConnectionSuccessPacket p) {
    _myId = p.id;
    _initializedController.add(new InitializedEvent(true, "Connection to server has been established"));
  }
  
  void _channelPacketHandler(ChannelPacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void _joinPacketHandler(JoinPacket p) {
    _otherId = p.id;
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void _idPacketHandler(IdPacket p) {
    _otherId = p.id;
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  void _byePacketHandler(ByePacket p) {
    PeerWrapper pw = _pm.findWrapper(p.id);
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
    
    if (_mediaStreamRemovedStreamController.hasSubscribers)
      _mediaStreamRemovedStreamController.add(new MediaStreamRemovedEvent(pw));
  }
  
  /**
   * Implements PeerDataEventListener onDateReceived
   */
  void onDataReceived(int buffered) {
    
  }
  
  /**
   * Implements PeerDataEventListener onChannelStateChanged
   */
  void onChannelStateChanged(DataPeerWrapper p, String state){
    
  }
  
  /**
   * Implements PeerDataEventListener onPacket
   */
  void onPacket(DataPeerWrapper pw, Packet p) {
    if (_packetController.hasSubscribers)
      _packetController.add(new PacketEvent(p, pw));
  }
  
  /**
   * Remote media stream available from peer
   */
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool main) {
   if (_mediaStreamAvailableStreamController.hasSubscribers)
     _mediaStreamAvailableStreamController.add(new MediaStreamAvailableEvent(ms, pw));
  }
  
  /**
   * Media stream was removed
   */
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    if (_mediaStreamRemovedStreamController.hasSubscribers)
      _mediaStreamRemovedStreamController.add(new MediaStreamRemovedEvent(pw));
  }
  
  void onPeerCreated(PeerWrapper pw) {
    if (pw is DataPeerWrapper) {
      pw.subscribe(this);
    }
  }
  /**
   * Implements PeerConnectionEventListener onPeerStateChanged
   */
  void onPeerStateChanged(PeerWrapper pw, String state) {
    if (_peerStateChangeController.hasSubscribers)
      _peerStateChangeController.add(new PeerStateChangedEvent(pw, state));
  }
  
  /**
   * Implements PeerConnectionEventListener onIceGatheringStateChanged
   */
  void onIceGatheringStateChanged(PeerWrapper pw, String state) {
    if (_iceGatheringStateChangeController.hasSubscribers)
      _iceGatheringStateChangeController.add(new IceGatheringStateChangedEvent(pw, state));
  }

  /**
   * Implements DataSourceConnectionEventListener onDataSourceMessage
   */
  void onDataSourceMessage(String m) {
    if (_dataSourceMessageController.hasSubscribers)
      _dataSourceMessageController.add(new DataSourceMessageEvent(m));
  }
  
  /**
   * implements DataSourceConnectionEventListener onCloseDataSource
   */
  void onCloseDataSource(String m) {
    if (_dataSourceCloseController.hasSubscribers)
      _dataSourceCloseController.add(new DataSourceCloseEvent(m));
    
    if (_signalingCloseController.hasSubscribers)
      _signalingCloseController.add(new SignalingCloseEvent(m));
  }
  
  /**
   * implements DataSourceConnectionEventListener onOpenDataSource
   */
  void onOpenDataSource(String m) {
    if (_dataSourceOpenController.hasSubscribers)
      _dataSourceOpenController.add(new DataSourceOpenEvent(m));
    
    if (_signalingOpenController.hasSubscribers)
      _signalingOpenController.add(new SignalingOpenEvent(m));
  }
  
  /**
   * implements DataSourceConnectionEventListener onDataSourceError
   */
  void onDataSourceError(String e) {
    if (_dataSourceErrorController.hasSubscribers)
      _dataSourceErrorController.add(new DataSourceErrorEvent(e));
    
    if (_signalingErrorController.hasSubscribers)
      _signalingErrorController.add(new SignalingErrorEvent(e));
  }
}