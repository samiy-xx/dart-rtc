part of rtc_client_tests;

typedef void onPacketCallback(Packet p);
typedef void onReadChunkCallback(int read, int leftToRead);

class BinaryEventListener implements BinaryDataReceivedEventListener {
  onPacketCallback _packetCallback;
  onReadChunkCallback _chunkCallback;
  
  set packetCallback(onPacketCallback c) => _packetCallback = c;
  set chunkCallback(onReadChunkCallback c) => _chunkCallback = c;
  
  void onPacket(Packet p) {
    if (_packetCallback != null)  
      _packetCallback(p);
  }
  
  void onReadChunk(int read, int leftToRead) {
    if (_chunkCallback != null)
      _chunkCallback(read, leftToRead);
  }

}