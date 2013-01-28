part of rtc_client;

/**
 * Type of data sent/received from datachannel
 */
class BinaryDataType {
  /* type of data */
  final int _type;
  
  /** String data type */
  static final BinaryDataType STRING = const BinaryDataType(0);
  
  /** Packet data type */
  static final BinaryDataType PACKET = const BinaryDataType(1);
  
  /** File data type */
  static final BinaryDataType FILE = const BinaryDataType(2);
  
  const BinaryDataType(int i) : _type = i;
  BinaryDataType.With(int i) : _type = i;
  
  int toInt() {
    return _type;
  }
}

