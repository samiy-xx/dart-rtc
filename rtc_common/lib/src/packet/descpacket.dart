part of rtc_common;

class DescriptionPacket implements Packet {
  DescriptionPacket() : super();
  DescriptionPacket.With(this.sdp, this.type, this.id, this.channelId);
  
  PacketType packetType = PacketType.DESC;
  String sdp;
  String id;
  String channelId;
  String type;
  
  Map toJson() {
    return {
      'sdp':sdp, 
      'type': type, 
      'id':id,
      'packetType':packetType.toString(), 
      'channelId':channelId
    };
  }
  
  static DescriptionPacket fromMap(Map m) {
    return new DescriptionPacket.With(m['sdp'], m['type'], m['id'], m['channelId']);
  }
}