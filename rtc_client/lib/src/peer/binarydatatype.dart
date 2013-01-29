part of rtc_client;

/**
 * Type of data sent/received from datachannel
 */
class BinaryDataType {
  /* type of data */
  final int _type;
  
  /** String data type */
  static final BinaryDataType STRING = const BinaryDataType(1);
  
  /** Packet data type */
  static final BinaryDataType PACKET = const BinaryDataType(2);
  
  /** File data type */
  static final BinaryDataType FILE = const BinaryDataType(3);
  
  const BinaryDataType(int i) : _type = i;
  BinaryDataType.With(int i) : _type = i;
  
  int toInt() {
    return _type;
  }
  
  operator ==(Object o) {
    if (o is int) {
      return (o as int) == toInt();
    }
    
    if (o is BinaryDataType) {
      return (o as BinaryDataType).toInt() == toInt();
    }
    
    return false;
  }
}

