part of signaling_packets;

class ByePacket implements Packet {
  ByePacket();
  ByePacket.With(this.userId, this.roomId);
  
  String packetType = PacketType.BYE;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static ByePacket fromMap(Map m) {
    return new ByePacket.With(m['userId'], m['roomId']);
  }
}
