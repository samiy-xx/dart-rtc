part of rtc_server_tests;

class ChannelTests {
  run() {
    group('ChannelTests', () {
      Channel c;
      ChannelContainer co;
      TestableServer s;
      
      String channelId;
      int channelLimit;
      
      setUp(() {
        channelId = "abc";
        channelLimit = 5;
        s = new TestableServer();
        co = new ChannelContainer(s);
        c = new Channel(co, channelId, channelLimit);
      });
      
      tearDown(() {
        c = null;
        co = null;
      });
      
      test("Channel, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("Channel, When created, has properties", () {
        expect(c.id, equals(channelId));
        expect(c.channelLimit, equals(channelLimit));
      });
      
    });
  }
}

class TestableServer implements Server {
  void sendToClient(WebSocketConnection, String p) {
    
  }
  void sendPacket(WebSocketConnection, Packet p) {
    
  }
  void listen([String ip, int port, String path]){
    
  }
}
