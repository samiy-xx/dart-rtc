part of signaling_packets;

class RandomUserPacket implements Packet {
  RandomUserPacket();
  RandomUserPacket.With(this.userId);
  
  String packetType = PacketType.RANDOM;
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'userId': userId
    };
  }
  
  static RandomUserPacket fromMap(Map m) {
      return new RandomUserPacket.With(m['userId']);
  }
}
