part of rtc_common;

class PeerCreatedPacket implements Packet {
  PeerCreatedPacket();
  PeerCreatedPacket.With(this.id);
  
  String packetType = "peercreated";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'id': id
    };
  }
  
  static PeerCreatedPacket fromMap(Map m) {
      return new PeerCreatedPacket.With(m['userId']);
  }
}
