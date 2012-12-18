part of signaling_packets;

/**
 * Base packet
 */
abstract class Packet {
  String packetType;
  Map toJson();
  String toString() {
    return JSON.stringify(toJson());
  }
}