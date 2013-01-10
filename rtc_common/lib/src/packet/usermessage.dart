part of rtc_common;

class UserMessage implements Packet {
  UserMessage();
  UserMessage.With(this.id, this.message);
  
  String packetType = "usermessage";
  String id = "";
  String message = "";
  
  Map toJson() {
    return {
      'packetType': packetType,
      'id': id,
      'message': message
    };
  }
  
  static UserMessage fromMap(Map m) {
      return new UserMessage.With(m['id'], m['message']);
  }
}
