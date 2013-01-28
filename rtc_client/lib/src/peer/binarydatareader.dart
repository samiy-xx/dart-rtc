part of rtc_client;

class BinaryDataReader extends BinaryData {
  BinaryDataType _type;
  
  BinaryDataReader() : super() {
    _type = BinaryDataType.STRING; 
  }
  /**
   * Reads an ArrayBuffer
   * Can be whole packet or partial
   */
  void readChunk(ArrayBuffer buf) {
    
    DataView v = new DataView(buf);
    int chunkLength = v.byteLength;
    
    for (int i = 0; i < v.byteLength; i++) {
      
      if (_currentReadState == BinaryReadState.INIT_READ) {
        if (v.getUint8(i) == FULL_BYTE) {
          _currentReadState = BinaryReadState.READ_TYPE;
        }
      }
      
      if (_currentReadState == BinaryReadState.READ_TYPE) {
        _type = new BinaryDataType.With(v.getUint32(i));
        _currentReadState = BinaryReadState.READ_LENGTH;
      }
      
      if (_currentReadState == BinaryReadState.READ_LENGTH) {
        _currentReadState = BinaryReadState.READ_CONTENT;
      }
      
      if (_currentReadState == BinaryReadState.READ_CONTENT) {
        if (v.getUint8(i) == NULL_BYTE && (v.getUint8(i+1) == _type.toInt() && v.getUint8(i+2) == NULL_BYTE)) {
          _currentReadState = BinaryReadState.FINISH_READ;
        }
      }
      /*int value;
      
      v.getUint8(i);
      
      if (value == FULL_BYTE && _currentReadState == BinaryReadState.INIT_READ) {
        _currentReadState = BinaryReadState.READ_LENGTH;
      }
      
      if (value == NULL_BYTE && _currentReadState == BinaryReadState.READ_CONTENT) {
        _currentReadState = BinaryReadState.FINISH_READ;
        _signalReadPacket(_readAndClearBuffer());
      }
      
      if (_currentReadState == BinaryReadState.READ_TYPE) {
        
        _currentReadState = BinaryReadState.READ_CONTENT;
      }
      
      if (_currentReadState == BinaryReadState.READ_LENGTH) {
        _leftToRead = value;
        _currentReadState = BinaryReadState.READ_TYPE;
      }
      
      if (_currentReadState == BinaryReadState.READ_CONTENT) {
        _buffer.add(value);
      }*/
    }
    _signalReadChunk(chunkLength);
  }
  
  
}