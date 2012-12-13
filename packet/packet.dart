library signaling_packets;
import 'dart:json';

part 'packettype.dart';
part 'helopacket.dart';
part 'descpacket.dart';
part 'icepacket.dart';
part 'userpacket.dart';
part 'roompacket.dart';
part 'byepacket.dart';
part 'joinpacket.dart';
part 'idpacket.dart';
part 'ackpacket.dart';
part 'pingpacket.dart';
part 'pongpacket.dart';
part 'packetfactory.dart';
part 'routepacket.dart';
part 'connectedpacket.dart';
part 'InvalidPacketException.dart';

abstract class Packet {
  String packetType;
  Map toJson();
  String toString() {
    return JSON.stringify(toJson());
  }
}
