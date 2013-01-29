part of rtc_client;

/**
 * Binary reader/writer for Datachannel
 */
class BinaryData extends GenericEventTarget<BinaryDataEventListener> {
  
  static final int NULL_BYTE = 0x00;
  static final int FULL_BYTE = 0xFF;
  
  /**
   * Da Constructor
   */
  BinaryData() {
  }
  
  static ArrayBuffer bufferFromString(String s) {
    ArrayBuffer buffer = new ArrayBuffer(s.length);
    DataView view = new DataView(buffer);
    
    for (int i = 0; i < s.length; i++) {
      view.setUint8(0, s.charCodeAt(i));
    }
    
    return buffer;
  }
  
  
  /**
   * Creates ArrayBuffer from Packet
   */
  static ArrayBuffer createBuffer(Packet p) {
    String packet = PacketFactory.get(p);
    ArrayBuffer buffer = new ArrayBuffer(packet.length * 2);
    Uint8Array view = new Uint8Array.fromBuffer(buffer);
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
    Uint8Array view = new Uint8Array.fromBuffer(buffer);
    return new String.fromCharCodes(view.toList());
  }
  
  /**
   * Converts ArrayBuffer to Packet
   */
  static Packet packetFromBuffer(ArrayBuffer buffer) {
    PacketFactory.getPacketFromString(stringFromBuffer(buffer));
  }
}

