part of signaling_packets;

class DescriptionPacket implements Packet {
  DescriptionPacket() : super();
  DescriptionPacket.With(this.sdp, this.type, this.userId, this.roomId);
  
  String packetType = PacketType.DESC;
  String sdp;
  String userId;
  String roomId;
  String type;
  
  Map toJson() {
    return {'sdp':sdp, 'type': type, 'userId':userId,'packetType':packetType, 'roomId':roomId};
  }
  
  static DescriptionPacket fromMap(Map m) {
    return new DescriptionPacket.With(m['sdp'], m['type'], m['userId'], m['roomId']);
  }
}