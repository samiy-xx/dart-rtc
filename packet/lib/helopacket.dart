part of signaling_packets;

class HeloPacket implements Packet {
  HeloPacket();
  HeloPacket.With(this.roomId, this.userId);
  
  String packetType = PacketType.HELO;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static HeloPacket fromMap(Map m) {
    return new HeloPacket.With(m['roomId'], m['userId']);
  }
}