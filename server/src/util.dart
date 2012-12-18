part of rtc_server;

class Util {
  static String generateId() {
    var chars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','o','p','q','r'];
    int max = chars.length - 1;
    
    StringBuffer buf = new StringBuffer();
    Random r = new Random();
    for (int i = 0; i < RANDOM_ID_LENGTH; i++) {
      buf.add(chars[r.nextInt(max)]);
    }
    
    return buf.toString();
  }
}
