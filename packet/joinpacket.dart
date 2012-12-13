part of signaling_packets;

class JoinPacket implements Packet {
  JoinPacket();
  JoinPacket.With(this.roomId, this.userId);
  
  String packetType = PacketType.JOIN;
  String roomId = "";
  String userId = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'roomId': roomId,
      'userId': userId
    };
  }
  
  static JoinPacket fromMap(Map m) {
    return new JoinPacket.With(m['roomId'], m['userId']);
  }
}