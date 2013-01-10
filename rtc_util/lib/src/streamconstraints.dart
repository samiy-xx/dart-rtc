part of rtc_util;

class StreamConstraints implements Constraints {
  int _bitRate;
  set bitRate(int value) => _bitRate = value;
  
  StreamConstraints() {
    _bitRate = 1000;
  }
  
  Map toMap() {
    return {
      'mandatory' : {},
      'optional' : [{'bandwidth': _bitRate}]
    };
  }
}