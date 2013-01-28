part of rtc_client;

/**
 * Binary reader/writer for Datachannel
 */
class BinaryData extends GenericEventTarget<BinaryDataEventListener> {
  
  static final int NULL_BYTE = 0x00;
  static final int FULL_BYTE = 0xFF;
  
  /* Create Array buffer slices att his size for sending */
  int _writeChunkSize = 16;
  
  /* Left to read on current packet */
  int _leftToRead = 0;
  
  /* Buffered data which is not complete */
  List<int> _buffer;
  
  /* Current read state */
  BinaryReadState _currentReadState = BinaryReadState.INIT_READ;
  
  /** Get the chunk size for writing */
  int get writeChunkSize => _writeChunkSize;
  
  /** Currently buffered data length */
  int get buffered => _buffer.length;
  
  /** Sets the chunk size for writing */
  set writeChunkSize(int i) => _writeChunkSize = i;
  
  /**
   * Da Constructor
   */
  BinaryData() {
    _buffer = new List<int>();
  }
  
  
  
  ArrayBuffer writeBufferFromBuffer(ArrayBuffer) {
    
  }
  
  void sendPacket(RtcDataChannel dc, Packet p) {
    dc.send(writeBufferFromPacket(p));
  }
  
  ArrayBuffer writeBufferFromPacket(Packet p) {
    String packet = PacketFactory.get(p);
    
    ArrayBuffer buffer = new ArrayBuffer(getSize(packet) * 2);
    DataView data = new DataView(buffer);
    
    int i = 0;
    int j = 0;
    
    // Set 0xFF at start
    data.setUint8(i++, FULL_BYTE);
    // Is packet
    data.setUint8(i++, FULL_BYTE);
    // Write content length
    data.setUint8(i++, packet.length);
    // Write content
    while (j < packet.length) {
      data.setUint8(i, packet.charCodeAt(j));
      i++;
      j++;
    }
    // write 0x00 to the end
    data.setUint8(i++, NULL_BYTE);
    return buffer;
  }
  
 /* void send(Packet p) {
    int WRITE_CHUNK_SIZE = 5;
    int sentBytes = 0;
    ArrayBuffer b = write(p);
    
    while (sentBytes < b.byteLength) {
      ArrayBuffer slice = b.slice(sentBytes, sentBytes + WRITE_CHUNK_SIZE);
      read(slice);
      sentBytes += WRITE_CHUNK_SIZE;
    }
    
  }*/
  
  Packet _readAndClearBuffer() {
    if (_buffer.length <= 0)
      throw new Exception("Buffer empty");
    
    String d = new String.fromCharCodes(_buffer.toList());
    return PacketFactory.getPacketFromString(d);
  }
  
  void _signalReadChunk(int chunkLength) {
    listeners.where((l) => l is BinaryDataReceivedEventListener).forEach((BinaryDataReceivedEventListener l) {
      l.onReadChunk(chunkLength);
    });
  }
  
  void _signalReadPacket(Packet p) {
    listeners.where((l) => l is BinaryDataReceivedEventListener).forEach((BinaryDataReceivedEventListener l) {
      l.onPacket(p);
    });
  }
  
  static int getSize(String p) {
    return p.length + 2 + 2 + 1;
  }
  
  /**
   * Creates ArrayBuffer from Packet
   */
  static ArrayBuffer createBuffer(Packet p) {
    String packet = PacketFactory.get(p);
    ArrayBuffer buffer = new ArrayBuffer(packet.length * 2);
    Uint16Array view = new Uint16Array.fromBuffer(buffer);
    for (int i = 0; i < packet.length; i++) {
      view[i] = packet.charCodeAt(i);
    }
    return buffer;
  }
  
  /**
   * Converts ArrayBuffer to string
   */
  static String stringFromBuffer(ArrayBuffer buffer) {
    Uint16Array view = new Uint16Array.fromBuffer(buffer);
    return new String.fromCharCodes(view.toList());
  }
  
  /**
   * Converts ArrayBuffer to Packet
   */
  static Packet packetFromBuffer(ArrayBuffer buffer) {
    PacketFactory.getPacketFromString(stringFromBuffer(buffer));
  }
}

