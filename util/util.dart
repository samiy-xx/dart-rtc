part of rtc_utils;

class Util {
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
  
  static String generateId(int length) {
    var chars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','o','p','q','r'];
    int max = chars.length - 1;
    
    StringBuffer buf = new StringBuffer();
    Random r = new Random();
    for (int i = 0; i < length; i++) {
      buf.add(chars[r.nextInt(max)]);
    }
    
    return buf.toString();
  }
}
