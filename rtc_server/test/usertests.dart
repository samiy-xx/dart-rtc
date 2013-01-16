part of rtc_server_tests;

class UserTests {
  TestableServer s;
  UserContainer uc;
  BaseUser u;
  String defaultId = "abc";
  
  run() {
    group('UserTests', () {
      setUp(() {
        s = new TestableServer();
        uc = new UserContainer(s);
        u = new BaseUser(uc, defaultId);
      });
      
      tearDown(() {
        u = null;
        uc = null;
        s = null;
      });
      
      test("User, When created, is not null", () {
        expect(u, isNotNull);
      });
      
      test("User, When created, has properties", () {
        expect(u.id, equals(defaultId));
      });
      
      test("User, talkTo, sets User", () {
        BaseUser target = getTestUser("a");
        u.talkTo(target);
        
        expect(u.talkers.contains(target), equals(true));
      });
      
    });
  }
  
  BaseUser getTestUser(String id) {
    return new BaseUser(uc, id);
  }
}

