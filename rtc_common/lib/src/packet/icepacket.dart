part of rtc_common;

class IcePacket implements Packet{
  IcePacket() : super();
  IcePacket.With(this.candidate, this.sdpMid, this.sdpMLineIndex, this.id) : super();
  
  String candidate;
  String sdpMid;
  int sdpMLineIndex;
  String id;
  PacketType packetType = PacketType.ICE;
  
  Map toJson() {
    return {
      'candidate':candidate,
      'sdpMid':sdpMid,
      'sdpMLineIndex':sdpMLineIndex,
      'packetType':packetType.toString(),
      'id':id
    };
  }
  
  static IcePacket fromMap(Map m) {
    return new IcePacket.With(m['candidate'], m['sdpMid'], m['sdpMLineIndex'], m['id']);
  }
}
