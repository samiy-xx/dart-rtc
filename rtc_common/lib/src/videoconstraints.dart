part of rtc_common;

/**
 * Constraints for getUserMedia
 */
class VideoConstraints implements Constraints{
  /* enabled audio */
  bool _audio = true;
  
  /* enabled video */
  bool _video = true;
  
  /* max width of the video */
  int _maxWidth;
  
  /* max height of the video */
  int _maxHeight;
  
  /* min width of the video */
  int _minWidth;
  
  /* min height of the video */
  int _minHeight;
  
  /* frame rate of the video */
  int _frameRate;
  
  /** Sets the max width of the video */
  set maxWidth(int value) => setMaxWidth(value);
  
  /** Sets the max height of the video */
  set maxHeight(int value) => setMaxHeight(value);
  
  /** Sets the min width of the video */
  set minWidth(int value) => setMinWidth(value);
  
  /** Sets the min height of the video */
  set minHeight(int value) => setMinHeight(value);
  
  /** Sets the video framerate */
  set frameRate(int value) => setFrameRate(value);
  
  VideoConstraints() {
    _frameRate = 30;
    _maxWidth = 1280;
    _maxHeight = 720;
    _minWidth = 800;
    _minHeight = 600;
  }
  
  /**
   * Sets the max width of the video
   */
  VideoConstraints setMaxWidth(int value) {
    _maxWidth = value;
    return this;
  }
  
  /**
   * Sets the max height of the video
   */
  VideoConstraints setMaxHeight(int value) {
    _maxHeight = value;
    return this;
  }
  
  /**
   * Sets the min width of the video
   */
  VideoConstraints setMinWidth(int value) {
    _minWidth = value;
    return this;
  }
  
  /**
   * Sets the min height of the video
   */
  VideoConstraints setMinHeight(int value) {
    _minHeight = value;
    return this;
  }
  
  /**
   * Sets the framerate of the video
   */
  VideoConstraints setFrameRate(int value) {
    _frameRate = value;
    return this;
  }
  
  /*
   * Implements Constraints toMap
   */
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
  }
}