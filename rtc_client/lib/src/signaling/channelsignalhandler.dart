part of rtc_client;

class ChannelSignalHandler extends SignalHandler{
  /* id for the channel */
  String _channelId;
  bool _isChannelOwner = false;
  bool get isChannelOwner => _isChannelOwner;
  
  String get channelId => _channelId;
  set channelId(String value) => _channelId = value;
  
  ChannelSignalHandler(DataSource ds) : super(ds) {
    registerHandler(PacketType.CHANNEL, handleChannelInfo);
  }
  
  void initialize([String host]) {
    if (_channelId == null)
      throw new Exception("channelId is null");
    
    super.initialize(host);
  }
  
  /**
   * Callback for websocket onopen
   */
  void onOpenDataSource(String e) {
    _log.Debug("(channelsignalhandler.dart) WebSocket connection opened, sending HELO, ${_dataSource.readyState}");
    _dataSource.send(PacketFactory.get(new HeloPacket.With(_channelId, "")));
  }
  
  void handleChannelInfo(ChannelPacket p) {
    _log.Info("(channelsignalhandler.dart) ChannelPacket owner=${p.owner}");
    _isChannelOwner = p.owner;
  }
  
  void handleJoin(JoinPacket packet) {
    if (packet.id == _id)
      _channelId = packet.channelId;
    
    _log.Debug("(channelsignalhandler.dart) JoinPacket channel ${packet.channelId} user ${packet.id}");
    PeerWrapper p = createPeerWrapper();
    p.channel = packet.channelId;
    p.id = packet.id;
    p.setAsHost(true);
  }
  
  void handleId(IdPacket id) {
    _log.Debug("(channelsignalhandler.dart) ID packet: channel ${id.channelId} user ${id.id}");
    if (id.id != null && !id.id.isEmpty) {
      PeerWrapper p = createPeerWrapper();
      p.id = id.id;
      p.channel = id.channelId;
    }
  }
}
