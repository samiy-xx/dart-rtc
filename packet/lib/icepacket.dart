part of signaling_packets;

class ICEPacket implements Packet{
  ICEPacket() : super();
  ICEPacket.With(this.candidate, this.sdpMid, this.sdpMLineIndex, this.userId, this.roomId) : super();
  
  String candidate;
  String sdpMid;
  int sdpMLineIndex;
  String roomId;
  String userId;
  String packetType = PacketType.ICE;
  
  Map toJson() {
    return {
      'candidate':candidate,
      'sdpMid':sdpMid,
      'sdpMLineIndex':sdpMLineIndex,
      'packetType':packetType,
      'userId':userId,
      'roomId':roomId
    };
  }
  
  static ICEPacket fromMap(Map m) {
    return new ICEPacket.With(m['candidate'], m['sdpMid'], m['sdpMLineIndex'], m['userId'], m['roomId']);
  }
}
