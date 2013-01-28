part of rtc_client;

class BinaryData {
  static final int NULL_BYTE = 0x00;
  static final int FULL_BYTE = 0xFF;
  static final int READ_CHUNK_SIZE = 6;
  static final int WRITE_CHUNK_SIZE = 6;
  
  static String state = "init";
  static int toRead = 0;
  static List<int> buffer = new List<int>();
  
  BinaryData() {
    buffer = new List<int>();
  }
  
  static void read(ArrayBuffer buf) {
    // ACTUALLY: READ ALL YOU CAN
    DataView v = new DataView(buf);
    for (int i = 0; i < v.byteLength; i++) {
      int value = v.getUint8(i);
      
      if (value == 0xFF && state == "init") {
        state = "length";
      }
      if (value == 0x00 && state == "content") {
        print ("final");
        state = "init";
        print(new String.fromCharCodes(buffer));
      }
      if (state == "length") {
        toRead = value;
        state = "content";
      }
      
      if (state == "content") {
        buffer.add(value);
      }
    }
  }
  
  static ArrayBuffer write(Packet p) {
    String packet = PacketFactory.get(p);
    
    ArrayBuffer buffer = new ArrayBuffer(getSize(packet) * 2);
    DataView data = new DataView(buffer);
    
    int i = 0;
    int j = 0;
    
    data.setUint8(i++, FULL_BYTE);
    data.setUint8(i++, packet.length);
    
    while (j < packet.length) {
      data.setUint8(i, packet.charCodeAt(j));
      i++;
      j++;
    }
    
    data.setUint8(i++, NULL_BYTE);
    
    
    return buffer;
  }
  
  static void send(Packet p) {
    int sentBytes = 0;
    ArrayBuffer b = write(p);
    
    while (sentBytes < b.byteLength) {
      ArrayBuffer slice = b.slice(sentBytes, sentBytes + WRITE_CHUNK_SIZE);
      read(slice);
      sentBytes += WRITE_CHUNK_SIZE;
    }
    
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

