part of rtc_common;

class ChannelPacket implements Packet {
  ChannelPacket() : super();
  ChannelPacket.With(this.id, this.channelId, this.owner, this.users);
  
  String packetType = PacketType.CHANNEL;
  String id;
  String channelId;
  bool owner;
  int users;
  
  Map toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'owner': owner,
      'users': users,
      'packetType': packetType
    };
  }
  
  static ChannelPacket fromMap(Map m) {
    return new ChannelPacket.With( 
        m['id'],
        m['channelId'], 
        m['owner'],
        m['users']
    );
  }
}

