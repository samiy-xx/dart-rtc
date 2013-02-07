part of rtc_common;

class RandomUserPacket implements Packet {
  RandomUserPacket();
  RandomUserPacket.With(this.id);
  
  PacketType packetType = PacketType.RANDOM;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static RandomUserPacket fromMap(Map m) {
      return new RandomUserPacket.With(m['id']);
  }
}
