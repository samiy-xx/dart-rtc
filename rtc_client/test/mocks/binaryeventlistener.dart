part of rtc_client_tests;

typedef void onPacketCallback(Packet p);
typedef void onReadChunkCallback(int read, int leftToRead);
typedef void onStringCallback(String s);

class BinaryEventListener implements BinaryDataReceivedEventListener {
  onPacketCallback _packetCallback;
  onReadChunkCallback _chunkCallback;
  onStringCallback _stringCallback;
  
  set packetCallback(onPacketCallback c) => _packetCallback = c;
  set chunkCallback(onReadChunkCallback c) => _chunkCallback = c;
  set stringCallback(onStringCallback c) => _stringCallback = c;
  
  void onPacket(Packet p) {
    if (_packetCallback != null)  
      _packetCallback(p);
  }
  
  void onReadChunk(int read, int leftToRead) {
    if (_chunkCallback != null)
      _chunkCallback(read, leftToRead);
  }

  void onString(String s) {
    if (_stringCallback != null)
      _stringCallback(s);
  }
}