part of rtc_common;

/**
 * Base packet
 */
abstract class Packet {
  /**
   * The type of the Packet
   */
  PacketType packetType;
  
  /**
   * The id of the sender
   */
  String id;
  
  /**
   * Returns the object as Map.
   * WebSocket sends only native objects and maps
   */
  Map toJson();
  
  /**
   * Calls JSON.stringify on Map returned by toJson
   */
  String toString() {
    return json.stringify(toJson());
  }
}