part of signaling_packets;

class PingPacket implements Packet {
  PingPacket();
  PingPacket.With(this.userId, this.roomId);
  
  String packetType = PacketType.PING;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static PingPacket fromMap(Map m) {
      return new PingPacket.With(m['userId'], m['roomId']);
  }
}
