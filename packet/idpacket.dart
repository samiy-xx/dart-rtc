part of signaling_packets;

class IdPacket implements Packet {
  IdPacket();
  IdPacket.With(this.userId, this.roomId);
  
  String packetType = PacketType.ID;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static IdPacket fromMap(Map m) {
    return new IdPacket.With(m['userId'], m['roomId']);
  }
}
