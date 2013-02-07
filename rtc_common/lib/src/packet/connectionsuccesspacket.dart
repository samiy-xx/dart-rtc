part of rtc_common;

class ConnectionSuccessPacket implements Packet {
  ConnectionSuccessPacket();
  ConnectionSuccessPacket.With(this.id);
  
  PacketType packetType = PacketType.CONNECTED;
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id
    };
  }
  
  static ConnectionSuccessPacket fromMap(Map m) {
      return new ConnectionSuccessPacket.With(m['id']);
  }
}