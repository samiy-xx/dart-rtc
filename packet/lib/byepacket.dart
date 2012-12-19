part of signaling_packets;

class ByePacket implements Packet {
  ByePacket();
  ByePacket.With(this.id);
  
  String packetType = PacketType.BYE;
 
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'uid': id
    };
  }
  
  static ByePacket fromMap(Map m) {
    return new ByePacket.With(m['id']);
  }
}
