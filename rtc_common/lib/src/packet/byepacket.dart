part of rtc_common;

/**
 * ByePacket.
 * Signal the server that client is disconnecting.
 */
class ByePacket implements Packet {
  ByePacket();
  ByePacket.With(this.id);
  
  PacketType packetType = PacketType.BYE;
 
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static ByePacket fromMap(Map m) {
    return new ByePacket.With(m['id']);
  }
}
