part of rtc_common;

class HeloPacket implements Packet {
  HeloPacket();
  HeloPacket.With(this.channelId, this.id);
  
  PacketType packetType = PacketType.HELO;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'channelId': channelId,
      'id': id
    };
  }
  
  static HeloPacket fromMap(Map m) {
    return new HeloPacket.With(m['channelId'], m['id']);
  }
}