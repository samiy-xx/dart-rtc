part of rtc_client;

class PacketEvent extends RtcEvent {
  Packet packet;
  PeerWrapper peerwrapper;
  String type;
  
  PacketEvent(Packet p, PeerWrapper pw) {
    packet = p;
    peerwrapper = pw;
    type = p.packetType;
  }
}

