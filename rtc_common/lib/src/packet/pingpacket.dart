part of rtc_common;

class PingPacket implements Packet {
  PingPacket();
  PingPacket.With(this.id);
  
  PacketType packetType = PacketType.PING;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static PingPacket fromMap(Map m) {
      return new PingPacket.With(m['id']);
  }
}
