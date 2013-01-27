part of rtc_server_tests;

class ChannelContainerTests {
  Server s;
  ChannelContainer c;
  
  run() {
    group('ChannelContainerTests', () {
      setUp(() {
        s = new TestableServer();
        c = new ChannelContainer(s);
      });
      
      tearDown(() {
        c = null;
        s = null;
      });
      
      test("ChannelContainer, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("ChannelContainer, When created, has properties", () {
        
      });
      
      
    });
  }
}

