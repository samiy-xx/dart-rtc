part of signaling_packets;

class AckPacket implements Packet {
  AckPacket();
  AckPacket.With(this.userId, this.roomId);
  
  String packetType = PacketType.ACK;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static AckPacket fromMap(Map m) {
      return new AckPacket.With(m['userId'], m['roomId']);
  }
}
