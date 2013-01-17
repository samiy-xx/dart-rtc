part of rtc_common;

/**
 * PacketFactory
 * Static methods to create Packet from Map or JSON String
 */
class PacketFactory {
  
  /**
   * Returns a packet from string input
   */
  static Packet getPacketFromString(String input) {
    try {
      return getPacketFromMap(json.parse(input));
    } catch(e) {
      throw new InvalidPacketException("Invalid packet", e);
    }
  }
  
  /**
   * Returns a packet from map
   */
  static Packet getPacketFromMap(Map m) {

    try {
      String pt = m['packetType'];
      Packet p;
      switch (pt) {
        case "helo":
          p = HeloPacket.fromMap(m);
          break;
        case "desc":
          p = DescriptionPacket.fromMap(m);
          break;
        case "ice":
          p = IcePacket.fromMap(m);
          break;
        case "connected":
          p = ConnectionSuccessPacket.fromMap(m);
          break;
        case "id":
          p = IdPacket.fromMap(m);
          break;
        case "join":
          p = JoinPacket.fromMap(m);
          break;
        case "pong":
          p = PongPacket.fromMap(m);
          break;
        case "ping":
          p = PingPacket.fromMap(m);
          break;
        case "bye":
          p = ByePacket.fromMap(m);
          break;
        case "queue":
          p = QueuePacket.fromMap(m);
          break;
        case "usermessage":
          p = UserMessage.fromMap(m);
          break;
        case "disconnected":
          p = Disconnected.fromMap(m);
          break;
        case "random":
          p = RandomUserPacket.fromMap(m);
          break;
        default:
          print("(packetfactory.dart) Unkown packet");
          p = null;
          break;
      }
      return p;
    } catch(e) {
      throw new InvalidPacketException("Packet was malformed", e);
    }
  }
  
  /**
   * Returns a json stringified Packet for websocket send
   */
  static String get(Packet p) {
    return json.stringify(p); 
  }
}