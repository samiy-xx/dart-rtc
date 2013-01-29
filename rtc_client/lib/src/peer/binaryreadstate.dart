part of rtc_client;

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

