part of signaling_packets;

class JoinPacket implements Packet {
  JoinPacket();
  JoinPacket.With(this.channelId, this.id);
  
  String packetType = PacketType.JOIN;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'channelId': channelId,
      'id': id
    };
  }
  
  static JoinPacket fromMap(Map m) {
    return new JoinPacket.With(m['channelId'], m['id']);
  }
}