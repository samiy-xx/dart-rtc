part of rtc_server_tests;


class QueueChannelTests {
  run() {
    group('QueueChannelTests', () {
      TestableWebSocketConnection ws;
      TestableServer server;
      ChannelContainer container;
      QueueChannel c;
  
      String channelId;
      String userId;
      int channelLimit;
      
      setUp(() {
        userId = Util.generateId(4);
        channelId = Util.generateId(4);
        server = new TestableServer();
        container = new ChannelContainer(server);
        channelLimit = 2;
        ws  = new TestableWebSocketConnection();
        c = new QueueChannel.With(container, channelId);
      });
      
      tearDown(() {
        c = null;
        ws = null;
        container = null;
        server = null;
      });
      
      test("QueueChannel, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("QueueChannel, When created, has properties", () {
        expect(c.id, equals(channelId));
        expect(c.channelLimit, equals(2));
        expect(c.userCount, equals(0));
      });
      
      test("QueueChannel, When created, has List for queue", () {
        expect(c.queue, isNotNull);
        expect(c.queue.length, equals(0));
      });
      
      test("QueueChannel, join user with userlimit exceeded, puts the user in queue", () {
        expect(c.join(TestFactory.getTestUser(TestFactory.getRandomId(), ws)), equals(true));
        
        User toBeQueued = TestFactory.getTestUser(TestFactory.getRandomId(), ws);
        expect(c.join(toBeQueued), equals(false));
        expect(c.userCount, equals(1));
        
        expect(c.queue.length, equals(1));
        expect(c.queue[0], equals(toBeQueued));
      });
      
      test("QueueChannel, space in channel gets available, Queued user gets popped out of queue", () {
        expect(c.join(TestFactory.getTestUser(TestFactory.getRandomId(), ws)), equals(true));
        
        User toBeQueued = TestFactory.getTestUser(TestFactory.getRandomId(), ws);
        expect(c.join(toBeQueued), equals(false));
        expect(c.userCount, equals(1));
        
        expect(c.queue.length, equals(1));
        expect(c.queue[0], equals(toBeQueued));
        
        c.leave(c.users[0]);
        c.next();
        expect(c.queue.length, equals(0));
        expect(c.users.contains(toBeQueued), equals(true));
      });
      
      test("QueueChannel, user enters/leaves queue, event is fired", () {
        MockChannelEventListener l = new MockChannelEventListener();
        User toBeQueued = TestFactory.getTestUser(TestFactory.getRandomId(), ws);
        User toBeMovedInQueue = TestFactory.getTestUser(TestFactory.getRandomId(), ws);
        c.subscribe(l);
        
        bool enteredQueue = false;
        bool leftQueue = false;
        bool movedInQueue = false;
        int queueCount = 0;
        int queuePosition = 0;
        int joinedQueueCount = 0;
        
        l.enterQueueCallback = (Channel channel, User user, int count, int position) {
          expect(channel, equals(c));
          queueCount = count;
          queuePosition = position;
          enteredQueue = true;
          joinedQueueCount++;
        };
        
        l.moveInQueueCallback = (Channel channel, User user, int count, int position) {
          expect(channel, equals(c));
          expect(user, equals(toBeMovedInQueue));
          queueCount = count;
          queuePosition = position;
          movedInQueue = true;
        };
        
        l.leaveQueueCallback = (Channel channel, User user) {
          expect(channel, equals(c));
          expect(user, equals(toBeQueued));
          leftQueue = true;
        };
        
        c.join(TestFactory.getTestUser(TestFactory.getRandomId(), ws));
        c.join(toBeQueued);
        c.join(toBeMovedInQueue);
        c.leave(c.users[0]);
        c.next();
        Timer t = new Timer(100, (_) {
          expect(enteredQueue, equals(true));
          expect(leftQueue, equals(true)); 
          expect(movedInQueue, equals(true));
          expect(joinedQueueCount, equals(2));
        });
      });
    });
    
  }
}




