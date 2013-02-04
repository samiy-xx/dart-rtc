part of rtc_common;

class ChannelPacket implements Packet {
  ChannelPacket() : super();
  ChannelPacket.With(this.id, this.channelId, this.owner, this.users);
  
  String packetType = PacketType.CHANNEL;
  String id;
  String channelId;
  bool owner;
  int users;
  
  Map toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'owner': owner,
      'users': users,
      'packetType': packetType
    };
  }
  
  static ChannelPacket fromMap(Map m) {
    return new ChannelPacket.With( 
        m['id'],
        m['channelId'], 
        m['owner'],
        m['users']
    );
  }
}

abstract class Command extends Packet {
  
}

class RemoveUserCommand implements Command {
  RemoveUserCommand();
  RemoveUserCommand.With(this.id, this.channelId);
  
  String packetType = PacketType.REMOVEUSER;
  String id;
  String channelId;
  
  Map toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'packetType': packetType
    };
  }
  
  static RemoveUserCommand fromMap(Map m) {
    return new RemoveUserCommand.With(m['id'], m['channelId']);
  }
}

