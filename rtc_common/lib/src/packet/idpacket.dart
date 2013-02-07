part of rtc_common;

class IdPacket implements Packet {
  IdPacket();
  IdPacket.With(this.id, this.channelId);
  
  PacketType packetType = PacketType.ID;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'channelId': channelId,
      'id': id
    };
  }
  
  static IdPacket fromMap(Map m) {
    return new IdPacket.With(m['id'], m['channelId']);
  }
}
