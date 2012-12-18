part of signaling_packets;

abstract class Packet {
  String packetType;
  Map toJson();
  String toString() {
    return JSON.stringify(toJson());
  }
}