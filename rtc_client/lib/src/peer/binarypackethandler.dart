part of rtc_client;

class BinaryPacketHandler {
  
  BinaryPacketHandler() {
    
  }
  
  ArrayBufferView createBufferView(Packet p) {
    String packet = PacketFactory.get(p);
    return new Uint8Array.fromList(packet.charCodes);
  }
}

