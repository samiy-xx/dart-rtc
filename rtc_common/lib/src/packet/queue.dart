part of rtc_common;

class QueuePacket implements Packet {
  QueuePacket() : super();
  QueuePacket.With(this.id, this.channelId, this.position);
  
  String packetType = PacketType.QUEUE;
  String id;
  String channelId;
  String position;
  
  Map toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'position': position,
      'packetType': packetType
    };
  }
  
  static QueuePacket fromMap(Map m) {
    return new QueuePacket.With(m['id'], m['channelId'], m['position']);
  }
}

class NextPacket implements Packet {
  NextPacket();
  NextPacket.With(this.id, this.channelId);
  
  String packetType = PacketType.NEXT;
  String id;
  String channelId;
  
  Map toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'packetType': packetType
    };
  }
  
  static NextPacket fromMap(Map m) {
    return new NextPacket.With(m['id'], m['channelId']);
  }
}


