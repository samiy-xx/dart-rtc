part of rtc_common;

class Disconnected extends Packet {
  Disconnected();
  Disconnected.With(this.id);
  
  PacketType packetType = PacketType.DISCONNECTED;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static Disconnected fromMap(Map m) {
    return new Disconnected.With(m['id']);
  }
}
