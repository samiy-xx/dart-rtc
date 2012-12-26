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
