part of rtc_common;

class PongPacket  implements Packet{
  PongPacket();
  
  String packetType = PacketType.PONG;
  String id;
  
  Map toJson() {
    return {
      'packetType': packetType 
    };
  }
  
  static PongPacket fromMap(Map m) {
      return new PongPacket();
  }
}
