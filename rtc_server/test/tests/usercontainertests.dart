part of rtc_server_tests;

class UserContainerTests {
  Server s;
  UserContainer c;
  
  run() {
    group('UserContainerTests', () {
      setUp(() {
        s = new TestableServer();
        c = new UserContainer(s);
      });
      
      tearDown(() {
        c = null;
        s = null;
      });
      
      test("User, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("User, When created, has properties", () {
        
      });
      
      
    });
  }
}


