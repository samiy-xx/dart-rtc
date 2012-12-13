part of signaling_packets;

class RoutePacket implements Packet {
  RoutePacket() : super();
  RoutePacket.With(this.caller, this.target, this.router);
  
  String packetType = PacketType.ROUTE;
  String caller;
  String target;
  String router;
  
  Map toJson() {
    return {'caller':caller, 'target': target, 'router':router,'packetType':packetType};
  }
  
  static RoutePacket fromMap(Map m) {
    return new RoutePacket.With(m['caller'], m['target'], m['router']);
  }
}
