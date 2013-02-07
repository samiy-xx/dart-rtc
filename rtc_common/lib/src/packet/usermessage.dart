part of rtc_common;

class UserMessage implements Packet {
  UserMessage();
  UserMessage.With(this.id, this.message);
  
  PacketType packetType = PacketType.USERMESSAGE;
  String id = "";
  
  String message = "";
  
  Map toJson() {
    return {
      'packetType': packetType.toString(),
      'id': id,
      
      'message': message
    };
  }
  
  static UserMessage fromMap(Map m) {
      return new UserMessage.With(m['id'], m['message']);
  }
}
