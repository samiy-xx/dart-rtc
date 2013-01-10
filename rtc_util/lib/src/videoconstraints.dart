part of rtc_util;

class VideoConstraints implements Constraints{
  bool _audio = true;
  bool _video = true;
  int _maxWidth;
  int _maxHeight;
  int _minWidth;
  int _minHeight;
  int _frameRate;
  
  set maxWidth(int value) => _maxWidth = value;
  set maxHeight(int value) => _maxHeight = value;
  set minWidth(int value) => _minWidth = value;
  set minHeight(int value) => _minHeight = value;
  set frameRate(int value) => _frameRate = value;
  
  VideoConstraints() {
    _frameRate = 30;
    _maxWidth = 1280;
    _maxHeight = 720;
    _minWidth = 800;
    _minHeight = 600;
  }
  
  Map toMap() {
    Map constraints = new Map();
    constraints['audio'] = _audio;
    if (!_video) {
      constraints['video'] = false;
    } else {
      constraints['video'] = {
        'mandatory': {
          'maxWidth' : _maxWidth,
          'maxHeight' : _maxHeight,
          'minWidth' : _minWidth,
          'minHeight' : _minHeight,
          'minFrameRate' : _frameRate,
        },
        'optional' : []                        
      };
    }
    
    return constraints;
    /*return {
      'audio' : _audio,
      'video' : {
        'mandatory': {
          'maxWidth' : _maxWidth,
          'maxHeight' : _maxHeight,
          'minWidth' : _minWidth,
          'minHeight' : _minHeight,
          'minFrameRate' : _frameRate,
          
        },
        'optional' : []
      } 
    };*/
  }
}