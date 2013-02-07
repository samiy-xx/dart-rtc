part of rtc_common;

class PeerCreatedPacket implements Packet {
  PeerCreatedPacket();
  PeerCreatedPacket.With(this.id);
  
  PacketType packetType = PacketType.PEERCREATED;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static PeerCreatedPacket fromMap(Map m) {
      return new PeerCreatedPacket.With(m['userId']);
  }
}
