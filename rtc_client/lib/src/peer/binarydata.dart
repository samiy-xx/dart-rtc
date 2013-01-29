part of rtc_client;

/**
 * Binary reader/writer for Datachannel
 */
class BinaryData extends GenericEventTarget<BinaryDataEventListener> {
  
  static final int NULL_BYTE = 0x00;
  static final int FULL_BYTE = 0xFF;
  
  /* Current read state */
  BinaryReadState _currentReadState = BinaryReadState.INIT_READ;
  
  /**
   * Da Constructor
   */
  BinaryData() {
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
   * Converts list of integers to string
   */
  static String stringFromList(List<int> l) {
    return new String.fromCharCodes(l);
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

