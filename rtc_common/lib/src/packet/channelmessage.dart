part of rtc_common;

class ChannelMessage implements Packet {
  ChannelMessage();
  ChannelMessage.With(this.id, this.channelId, this.message);
  
  PacketType packetType = PacketType.CHANNELMESSAGE;
  String id = "";
  String channelId = "";
  String message = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id,
      'channelId': channelId,
      'message': message
    };
  }
  
  static ChannelMessage fromMap(Map m) {
      return new ChannelMessage.With(m['id'], m['channelId'], m['message']);
  }
}

