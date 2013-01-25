part of rtc_server_tests;

class TestFactory {
  static User getTestUser(String id, WebSocketConnection ws) {
    return new User(id, ws);
  }
  
  static String getRandomId() {
    return Util.generateId(4);
  }
}

