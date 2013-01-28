part of rtc_client;

class BinaryDataWriter extends BinaryData {
  BinaryDataWriter() : super() {
    
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
  
  ArrayBuffer createHeaderFor(BinaryDataType t, int length) {
    ArrayBuffer buffer = new ArrayBuffer(length);
    DataView data = new DataView(buffer);
    
    // Write 0xFF at start
    data.setUint8(0, FULL_BYTE);
    // Write data type
    data.setUint8(1, t.toInt());
    // Write content length
    if (t == BinaryDataType.PACKET) {
      data.setUint8(2, length);
    } else if (t == BinaryDataType.STRING) {
      data.setUint16(2, length);
    } else {
      data.setUint32(2, length);
    }
  }
  
  ArrayBuffer createFooterFor(BinaryDataType t) {
    ArrayBuffer buffer = new ArrayBuffer(3);
    DataView data = new DataView(buffer);
    
    // Set 0x00 at start
    data.setUint8(0, NULL_BYTE);
    // Write data type
    data.setUint8(1, t.toInt());
    // Set 0x00 at end
    data.setUint8(2, NULL_BYTE);
  }
  
  void addFooterTo(ArrayBuffer buffer, BinaryDataType t) {
    Uint16Array a = new Uint8Array.fromBuffer(buffer);
    Uint16Array b = new Uint8Array.fromBuffer(createFooterFor(t));
    a.addAll(b);
    
  }
}