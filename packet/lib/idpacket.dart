part of signaling_packets;

class IdPacket implements Packet {
  IdPacket();
  IdPacket.With(this.id, this.channelId);
  
  String packetType = PacketType.ID;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'channelId': channelId,
      'id': id
    };
  }
  
  static IdPacket fromMap(Map m) {
    return new IdPacket.With(m['id'], m['channelId']);
  }
}
