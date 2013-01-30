part of rtc_client;

class BinaryDataReader extends BinaryData {
  /* data type for currently processed object */
  BinaryDataType _type;
  
  ArrayBuffer _latest;
  
  /* Length of data for currently processed object */
  int _length;
  
  /* Left to read on current packet */
  int _leftToRead = 0;
  
  /* Buffer for unfinsihed data */
  List<int> _buffer;
  
  bool _bufferData = true;
  
  /* Logger */
  Logger _log = new Logger();
  
  /** Currently buffered unfinished data */
  int get buffered => _buffer.length;
  
  /* Current read state */
  BinaryReadState _currentReadState = BinaryReadState.INIT_READ;
  
  /** Current read state */
  BinaryReadState get currentReadState => _currentReadState;
  
  int get leftToRead => _leftToRead;
  
  set bufferData(bool b) => _bufferData = b;
  /**
   * da mighty constructor
   */
  BinaryDataReader() : super() {
    _type = BinaryDataType.STRING;
    _length = 0;
    _buffer = new List<int>();
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
        if (v.getUint8(i) == BinaryData.NULL_BYTE && v.getUint8(i+1) == _type.toInt() && v.getUint8(i+2) == BinaryData.NULL_BYTE) {
          _process_end();
        } else {
          _process_content(v.getUint8(i));
        }
      }
      
    }
    _latest = buf;
    _signalReadChunk(chunkLength);
  }
  
  ArrayBuffer getLatestChunk() {
    return _latest;
  }
  /*
   * Read the 0xFF byte and switch state
   */
  void _process_init_read(int b) {
    if (b == BinaryData.FULL_BYTE)
      _currentReadState = BinaryReadState.READ_TYPE;
  }
  
  /*
   * Read the BinaryDataType of the object
   */
  void _process_read_type(int b) {
    _type = new BinaryDataType.With(b);
    _currentReadState = BinaryReadState.READ_LENGTH;
  }
  
  /*
   * Read the content length
   * FILE = unsigned 32 bit integer
   * STRING = unsigned 16 bit integer
   * PACKET = unsigned 8 bit integer
   */
  void _process_read_length(int index, DataView dv) {
    if (_type == BinaryDataType.FILE)
      _length = dv.getUint32(index);
    else if (_type == BinaryDataType.STRING)
      _length = dv.getUint16(index);
    if (_type == BinaryDataType.PACKET)
      _length = dv.getUint8(index);
    else
      _length = -1;
    
    _leftToRead = _length;
    _currentReadState = BinaryReadState.READ_CONTENT;
  }
  
  /*
   * Push data to buffer
   */
  void _process_content(int b) {
    if (_bufferData)
      _buffer.add(b);
    _leftToRead -= 1;
  }
  
  /*
   * Process end of read
   */
  void _process_end() {
    _currentReadState = BinaryReadState.FINISH_READ;
    _leftToRead = 0;
    _processBuffer();
  }
  
  /*
   * Process the buffer contents
   */
  void _processBuffer() {
    if (_type == BinaryDataType.PACKET) {
      try {
        Packet p = PacketFactory.getPacketFromString(new String.fromCharCodes(_buffer));
        _signalReadPacket(p);
      } on InvalidPacketException catch(e, s) {
        new Logger().Error(e.msg);
      }
    } else if (_type == BinaryDataType.STRING) {
      try {
        String s = BinaryData.stringFromList(_buffer);
        _signalReadString(s);
      } catch (e) {
        new Logger().Error(e);
      }
    }
  }
  
  void bufferFromBlob(Blob b) {
    FileReader r = new FileReader();
    r.readAsArrayBuffer(b);
    
    r.onLoadEnd.listen((ProgressEvent e) {
      listeners.where((l) => l is BinaryBlobReadEventListener).forEach((BinaryBlobReadEventListener l) {
        l.onLoadDone(r.result);
      });
    });
    
    r.onProgress.listen((ProgressEvent e) {
      listeners.where((l) => l is BinaryBlobReadEventListener).forEach((BinaryBlobReadEventListener l) {
        l.onProgress();
      });
    });
  }
  
  /*
   * Signal listeners that a chunk has been read
   */
  void _signalReadChunk(int chunkLength) {
    listeners.where((l) => l is BinaryDataReceivedEventListener).forEach((BinaryDataReceivedEventListener l) {
      l.onReadChunk(chunkLength, _leftToRead);
    });
  }
  
  /*
   * Packet has been read
   */
  void _signalReadPacket(Packet p) {
    listeners.where((l) => l is BinaryDataReceivedEventListener).forEach((BinaryDataReceivedEventListener l) {
      l.onPacket(p);
    });
  }
  
  void _signalReadString(String s) {
    listeners.where((l) => l is BinaryDataReceivedEventListener).forEach((BinaryDataReceivedEventListener l) {
      l.onString(s);
    });
  }
  /**
   * Resets the reader
   */
  void reset() {
    _buffer.clear();
    _currentReadState = BinaryReadState.INIT_READ;
    _leftToRead = 0;
  }
  
}