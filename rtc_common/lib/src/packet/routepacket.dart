part of rtc_common;

class RoutePacket implements Packet {
  RoutePacket() : super();
  RoutePacket.With(this.id, this.target, this.router);
  
  String packetType = PacketType.ROUTE;
  String id;
  String target;
  String router;
  
  Map toJson() {
    return {'id':id, 'target': target, 'router':router,'packetType':packetType};
  }
  
  static RoutePacket fromMap(Map m) {
    return new RoutePacket.With(m['id'], m['target'], m['router']);
  }
}
