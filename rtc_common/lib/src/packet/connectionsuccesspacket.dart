part of rtc_common;

class ConnectionSuccessPacket implements Packet {
  ConnectionSuccessPacket();
  ConnectionSuccessPacket.With(this.id);
  
  String packetType = "connected";
  String id = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'id': id
    };
  }
  
  static ConnectionSuccessPacket fromMap(Map m) {
      return new ConnectionSuccessPacket.With(m['id']);
  }
}