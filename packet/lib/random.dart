part of signaling_packets;

class RandomUserPacket implements Packet {
  RandomUserPacket();
  RandomUserPacket.With(this.id);
  
  String packetType = PacketType.RANDOM;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'id': id
    };
  }
  
  static RandomUserPacket fromMap(Map m) {
      return new RandomUserPacket.With(m['id']);
  }
}
