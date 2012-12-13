part of signaling_packets;

class PongPacket  implements Packet{
  PongPacket();
  
  String packetType = PacketType.PONG;
  
  
  Map toJson() {
    return {
      'packetType': packetType 
    };
  }
  
  static PongPacket fromMap(Map m) {
      return new PongPacket();
  }
}
