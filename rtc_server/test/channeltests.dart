part of rtc_server_tests;

class ChannelTests {
  run() {
    group('ChannelTests', () {
      TestableWebSocketConnection ws;
      Channel c;
  
      String channelId;
      int channelLimit;
      
      setUp(() {
        channelId = "abc";
        channelLimit = 5;
        ws  = new TestableWebSocketConnection();
        c = new Channel(channelId, channelLimit);
      });
      
      tearDown(() {
        c = null;
      });
      
      test("Channel, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("Channel, When created, has properties", () {
        expect(c.id, equals(channelId));
        expect(c.channelLimit, equals(channelLimit));
        expect(c.userCount, equals(0));
      });
      
      test("Channel, User List, Can add users", () {
        String userId = Util.generateId(4);
        User u = TestFactory.getTestUser(userId, ws);
 
        c.join(u);
        
        expect(c.userCount, equals(1));
      });
      
      test("Channel, User List, Can remove users", () {
        
      });
    });
  }
}


