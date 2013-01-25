part of rtc_server_tests;


class TestableServer implements Server {
  List<Packet> _packetsSent;
  List<Packet> get packetsSent => _packetsSent;
  
  TestableServer() : super() {
    _packetsSent = new List<Packet>();
  }
  
  void sendToClient(WebSocketConnection, String packet) {
    Packet p = PacketFactory.getPacketFromString(packet);
    _packetsSent.add(p);
  }
  
  void sendPacket(WebSocketConnection, Packet p) {
    _packetsSent.add(p);
  }
  
  void listen([String ip, int port, String path]){
    
  }
}

