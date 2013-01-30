part of rtc_client;

class BinaryDataWriter extends BinaryData {
  /* Create Array buffer slices att his size for sending */
  int _writeChunkSize = 16;
  
  /** Get the chunk size for writing */
  int get writeChunkSize => _writeChunkSize;
   
  /** Sets the chunk size for writing */
  set writeChunkSize(int i) => _writeChunkSize = i;
  
  BinaryDataWriter() : super() {
    
  }
  
  /*ArrayBuffer writeBufferFromPacket(Packet p) {
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
  */
  ArrayBuffer createPacketBuffer(Packet p) {
    String packet = PacketFactory.get(p);
    
    ArrayBuffer buffer = new ArrayBuffer(packet.length);
    DataView data = new DataView(buffer);
    int i = 0;
    while (i < packet.length) {
      data.setUint8(i, packet.charCodeAt(i));
      i++;
    }
    return buffer;
  }
  
  int _calculateHeaderSize(BinaryDataType t) {
    int out = 0;
    if (t == BinaryDataType.PACKET)
      out = 3;
    else if (t == BinaryDataType.STRING)
      out = 4;
    else if (t == BinaryDataType.FILE)
      out = 6;
    return out;
  }
  
  int _calculateFooterSize() {
    return 3;
  }
  
  ArrayBuffer createHeaderFor(BinaryDataType t, int length) {
    ArrayBuffer buffer = new ArrayBuffer(_calculateHeaderSize(t));
    DataView data = new DataView(buffer);
    
    // Write 0xFF at start
    data.setUint8(0, BinaryData.FULL_BYTE);
    // Write data type
    data.setUint8(1, t.toInt());
    // Write content length
    if (t == BinaryDataType.PACKET) {
      // Takes 1 byte
      data.setUint8(2, length);
    } else if (t == BinaryDataType.STRING) {
      // Takes 2 bytes
      data.setUint16(2, length);
    } else {
      // takes 4 bytes
      data.setUint32(2, length);
    }
    
    return buffer;
  }
  
  ArrayBuffer createFooterFor(BinaryDataType t) {
    ArrayBuffer buffer = new ArrayBuffer(3);
    DataView data = new DataView(buffer);
    
    // Set 0x00 at start
    data.setUint8(0, BinaryData.NULL_BYTE);
    // Write data type
    data.setUint8(1, t.toInt());
    // Set 0x00 at end
    data.setUint8(2, BinaryData.NULL_BYTE);
    
    return buffer;
  }
  
  ArrayBuffer mergeHeaderTo(ArrayBuffer buffer, BinaryDataType t) {
    // Content buffer should have all Uint8 so can just use byteLength
    ArrayBuffer resultBuffer = new ArrayBuffer(buffer.byteLength + _calculateHeaderSize(t));
    ArrayBuffer headerBuffer = createHeaderFor(t, buffer.byteLength);
    
    Uint8Array contentArrayView = new Uint8Array.fromBuffer(buffer);
    DataView headerView = new DataView(headerBuffer);
    DataView resultView = new DataView(resultBuffer);
    
    
    resultView.setUint8(0, headerView.getUint8(0));
    resultView.setUint8(1, headerView.getUint8(1));
    if (t == BinaryDataType.PACKET)
      resultView.setUint8(2, headerView.getUint8(2));
    else if (t == BinaryDataType.PACKET)
      resultView.setUint16(2, headerView.getUint16(2));
    else if (t == BinaryDataType.FILE)
      resultView.setUint32(2, headerView.getUint32(2));
    
    
    for (int i = 0; i < contentArrayView.length; i++) {
      resultView.setUint8(i + 3, contentArrayView[i]);
    }
    return resultBuffer;
  }
  
  ArrayBuffer mergeFooterTo(ArrayBuffer buffer, BinaryDataType t) {
    Uint8Array a = new Uint8Array.fromBuffer(buffer);
    Uint8Array b = new Uint8Array.fromBuffer(createFooterFor(t));
    
    ArrayBuffer resultBuffer = new ArrayBuffer(a.length + b.length);
    Uint8Array writer = new Uint8Array.fromBuffer(resultBuffer);
    
    writer.setElements(a, 0);
    int position = a.length;
    writer.setElements(b, position);
    
    return resultBuffer;
  }
}