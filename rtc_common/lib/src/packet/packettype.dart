part of rtc_common;


class PacketType {
  /**
   * HELO Packet is sent to server when creating the connection
   */
  static final PacketType HELO = const PacketType("helo");
  
  /**
   * DESC packet contains the sdp info
   */
  static final PacketType DESC = const PacketType("desc");
  
  /**
   * Ice packets contain the information on peers will connect trough different routers and nats
   */
  static final PacketType ICE = const PacketType("ice");
  static final PacketType USER = const PacketType("user");
  static final PacketType BYE = const PacketType("bye");
  
  /**
   * JOIN Packet informs users on channel about new user joining
   */
  static final PacketType JOIN = const PacketType("join");
  
  /**
   * ID Packet informs the user joining a channel about existing users
   */
  static final PacketType ID = const PacketType("id");
  static final PacketType ACK = const PacketType("ack");
  
  /**
   * Keepalive controls, Server send PING packet and expects the client to respond with PONG
   */
  static final PacketType PING = const PacketType("ping");
  
  /**
   * Keepalive controls, Client must respond with PONG to a PING packet from server
   */
  static final PacketType PONG = const PacketType("pong");
  static final PacketType CONNECTED = const PacketType("connected");
  static final PacketType RANDOM = const PacketType("random");
  static final PacketType DISCONNECTED = const PacketType("disconnected");
  static final PacketType QUEUE = const PacketType("queue");
  static final PacketType CHANNEL = const PacketType("channel");
  static final PacketType FILE = const PacketType("file");
  
  /**
   * NEXT packet requests a new user from queue
   */
  static final PacketType NEXT = const PacketType("next");
  
  /**
   * REMOVEUSER packet requests that a user is removed from channel
   */
  static final PacketType REMOVEUSER = const PacketType("removeuser");
  static final PacketType USERMESSAGE = const PacketType("usermessage");
  
  /**
   * CHANNELMESSAGE packet sends a message to everyone in channel
   */
  static final PacketType CHANNELMESSAGE = const PacketType("channelmessage");
  static final PacketType PEERCREATED = const PacketType("peercreated");
  final String type;
  const PacketType(this.type);
  String toString() => type;
}
