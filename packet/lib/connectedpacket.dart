part of signaling_packets;

class ConnectedPacket implements Packet {
  ConnectedPacket() : super();
  ConnectedPacket.With(this.caller, this.target);
  
  String packetType = PacketType.ROUTE;
  String caller;
  String target;
  
  
  Map toJson() {
    return {'caller':caller, 'target': target,'packetType':packetType};
  }
  
  static ConnectedPacket fromMap(Map m) {
    return new ConnectedPacket.With(m['caller'], m['target']);
  }
}
