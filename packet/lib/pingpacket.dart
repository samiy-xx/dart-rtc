part of signaling_packets;

class PingPacket implements Packet {
  PingPacket();
  PingPacket.With(this.userId);
  
  String packetType = PacketType.PING;
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'userId': userId
    };
  }
  
  static PingPacket fromMap(Map m) {
      return new PingPacket.With(m['userId']);
  }
}
