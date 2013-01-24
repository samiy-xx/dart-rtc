part of rtc_server_tests;

class UserTests {
  TestableWebSocketConnection ws;
  User u;
  String defaultId = "abc";
  
  run() {
    group('UserTests', () {
      setUp(() {
        ws = new TestableWebSocketConnection();
        u = new User(defaultId, ws);
      });
      
      tearDown(() {
        u = null;
        ws = null;
      });
      
      test("User, When created, is not null", () {
        expect(u, isNotNull);
      });
      
      test("User, When created, has properties", () {
        expect(u.id, equals(defaultId));
      });
      
      test("User, talkTo, sets User", () {
        User target = TestFactory.getTestUser("a", ws);
        u.talkTo(target);
        
        expect(u.talkers.contains(target), equals(true));
      });
      
    });
  }
  
  
  
}



