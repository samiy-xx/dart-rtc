/**
 * util.dart
 * Copyright (c) 2013 Sami Ylönen sami.ylonen@gmail.com
 */

part of rtc_utils;

/**
 * Utility class
 */
class Util {
  
  /**
   * Method to return aspectratio based on width and height
   */
  static String aspectRatio(int x, int y) {
    double value = x.toDouble() / y.toDouble();
    if (value > 1.7)
      return "16:9";
    else
      return "4:3";
  }
  
  // For future generations.. ~/ integer division
  
  static int getHeight(int width, String aspectRatio) {
    return aspectRatio == "4:3" ? width * 3 ~/ 4 : width * 9 ~/ 16 ;
  }
  
  static int getWidth(int height, String aspectRatio) {
    return aspectRatio == "4:3" ? height * 4 ~/ 3 : height * 16 ~/ 9;
  }
  
  /**
   * Generates more or less random string
   * @param length of the requied random string
   */
  static String generateId(int length) {
    // Characters used in string generation
    // TODO: Is there some other way to get all characters?
    var chars = ['a','b','c','d','e',
                 'f','g','h','i','j',
                 'k','l','m','o','p',
                 'q','r','s','t','u',
                 'v','w','x','y','z'
                 '0','1','2','3','4'
                 '5','6','7','8','9'];
    
    int max = chars.length - 1;
    
    StringBuffer buf = new StringBuffer();
    Random r = new Random();
    for (int i = 0; i < length; i++) {
      buf.add(chars[r.nextInt(max)]);
    }
    
    return buf.toString();
  }
}

abstract class Constraints {
  Map toMap();
}

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
