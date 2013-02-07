part of rtc_common;

class JoinPacket implements Packet {
  JoinPacket();
  JoinPacket.With(this.channelId, this.id);
  
  PacketType packetType = PacketType.JOIN;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'channelId': channelId,
      'id': id
    };
  }
  
  static JoinPacket fromMap(Map m) {
    return new JoinPacket.With(m['channelId'], m['id']);
  }
}