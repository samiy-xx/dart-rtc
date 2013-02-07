part of rtc_common;

class PongPacket  implements Packet{
  PongPacket();
  
  PacketType packetType = PacketType.PONG;
  String id;
  
  Map toJson() {
    return {
      'packetType': packetType.toString()
    };
  }
  
  static PongPacket fromMap(Map m) {
      return new PongPacket();
  }
}
