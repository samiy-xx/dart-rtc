part of signaling_packets;

class HeloPacket implements Packet {
  HeloPacket();
  HeloPacket.With(this.channelId, this.id);
  
  String packetType = PacketType.HELO;
  String channelId = "";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'channelId': channelId,
      'id': id
    };
  }
  
  static HeloPacket fromMap(Map m) {
    return new HeloPacket.With(m['channelId'], m['id']);
  }
}