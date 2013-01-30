part of rtc_server;

class BinaryReader {
  final int FULL_BYTE = 0xFF;
  final int NULL_BYTE = 0x00;
  int _length = 0;
  /* Buffer for unfinsihed data */
  List<int> _buffer;
  
  bool _isComplete;
  /** Currently buffered unfinished data */
  int get buffered => _buffer.length;
  bool get isComplete => _isComplete;
  /* Current read state */
  BinaryReadState _currentReadState = BinaryReadState.INIT_READ;
  
  /** Current read state */
  BinaryReadState get currentReadState => _currentReadState;
  
  BinaryReader() : super() {
    _buffer = new List<int>();
    readChunk(_buffer);
  }
  
  String getCompleted() {
    if (!_isComplete)
      return null;
    String s = new String.fromCharCodes(_buffer);
    reset();
    return s;
  }
  /**
  * Reads an ArrayBuffer
  * Can be whole packet or partial
  */
  void readChunk(Uint8List buf) {
    
    /*ByteArray v = buf.asByteArray();
    
    //DataView v = new DataView(buf);
    int chunkLength = buf.length;
    
    for (int i = 0; i < chunkLength; i++) {
      
      if (_currentReadState == BinaryReadState.INIT_READ) {
        _process_init_read(v.getUint8(i));
        continue;
      }
      
      if (_currentReadState == BinaryReadState.READ_TYPE) {
        _process_read_type(v.getUint8(i));
        continue;
      }
      
      if (_currentReadState == BinaryReadState.READ_LENGTH) {
        _process_read_length(i, v);
        continue;
      }
      
      if (_currentReadState == BinaryReadState.READ_CONTENT) {
        if (v.getUint8(i) == NULL_BYTE && v.getUint8(i+1) != null && v.getUint8(i+2) == NULL_BYTE) {
          _process_end();
        } else {
          _process_content(v.getUint8(i));
        }
      }
      
    }*/
    
    //_signalReadChunk(chunkLength);
  }
  
  /*
   * Read the 0xFF byte and switch state
   */
  void _process_init_read(int b) {
    if (b == FULL_BYTE)
      _currentReadState = BinaryReadState.READ_TYPE;
  }
  
  /*
   * Read the BinaryDataType of the object
   */
  void _process_read_type(int b) {
    _currentReadState = BinaryReadState.READ_LENGTH;
  }
  
  /*
   * Read the content length
   * FILE = unsigned 32 bit integer
   * STRING = unsigned 16 bit integer
   * PACKET = unsigned 8 bit integer
   */
  void _process_read_length(int index, ByteArray dv) {
    _length = dv.getUint8(index);
    _currentReadState = BinaryReadState.READ_CONTENT;
  }
  
  /*
   * Push data to buffer
   */
  void _process_content(int b) {
    
      _buffer.add(b);
    
  }
  
  /*
   * Process end of read
   */
  void _process_end() {
    _currentReadState = BinaryReadState.FINISH_READ;
    _isComplete = true;
    
  }
  
  /*
   * Process the buffer contents
   */
  void _processBuffer() {
    
      try {
        Packet p = PacketFactory.getPacketFromString(new String.fromCharCodes(_buffer));
        //_signalReadPacket(p);
      } on InvalidPacketException catch(e, s) {
        new Logger().Error(e.msg);
      }
    
  }
  /**
   * Resets the reader
   */
  void reset() {
    _buffer.clear();
    _currentReadState = BinaryReadState.INIT_READ;
    _isComplete = false;
  }
}

class BinaryReadState {
  final int _state;
  static final BinaryReadState INIT_READ = const BinaryReadState(0);
  static final BinaryReadState READ_LENGTH = const BinaryReadState(1);
  static final BinaryReadState READ_TYPE = const BinaryReadState(2);
  static final BinaryReadState READ_CONTENT = const BinaryReadState(3);
  static final BinaryReadState FINISH_READ = const BinaryReadState(4);
  
  const BinaryReadState(int s) : _state = s;
  
  operator ==(Object o) {
    if (!(o is BinaryReadState))
      return false;
    
    BinaryReadState brs = o as BinaryReadState;
    return brs._state == _state; 
  }
  
  String toString() => _state.toString();
}