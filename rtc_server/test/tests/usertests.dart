part of rtc_server_tests;

class UserTests {
  TestableWebSocketConnection ws;
  User u;
  String defaultId = "abc";
  int timeCreated;
  
  run() {
    group('UserTests', () {
      setUp(() {
        ws = new TestableWebSocketConnection();
        u = new User(defaultId, ws);
        timeCreated = new Date.now().millisecondsSinceEpoch;
      });
      
      tearDown(() {
        u = null;
        ws = null;
        timeCreated = null;
      });
      
      test("User, When created, is not null", () {
        expect(u, isNotNull);
      });
      
      test("User, When created, has properties", () {
        expect(u.id, equals(defaultId));
        expect(u.timeSinceLastConnection, equals(timeCreated));
        expect(u.lastActivity, equals(timeCreated));
        expect(u.isTalking, equals(false));
        expect(u.talkers.length, equals(0));
      });
      
      test("User, properties, can be set", () {
        int t = 1;
        String newId = "dart";
        
        u.id = newId;
        u.lastActivity = t;
        u.timeSinceLastConnection = t;
        
        expect(u.id, equals(newId));
        expect(u.lastActivity, equals(t));
        expect(u.timeSinceLastConnection, equals(t));
      });
      
      test("User, talkTo, sets User", () {
        User target = TestFactory.getTestUser("a", ws);
        u.talkTo(target);
        
        expect(u.talkers.length, equals(1));
        expect(u.talkers.contains(target), equals(true));
      });
     
      test("User, hangup, removes user from talkers", () {
        User target = TestFactory.getTestUser("a", ws);
        
        u.talkTo(target);
        expect(u.talkers.length, equals(1));
        expect(u.talkers.contains(target), equals(true));
        
        u.hangup(target);
        expect(u.talkers.length, equals(0));
      });
      
      test("User, needsping, returns correct", () {
        int t = new Date.now().millisecondsSinceEpoch;
        int pingNeededTime = t - DEAD_SOCKET_CHECK;
        
        u.lastActivity = pingNeededTime;
        expect(u.needsPing(t), equals(true));
        
        u.lastActivity += 1;
        expect(u.needsPing(t), equals(false));
      });
      
      test("User, needskill, returns correct", () {
        int t = new Date.now().millisecondsSinceEpoch;
        int killNeededTime = t - DEAD_SOCKET_KILL;
        
        u.lastActivity = killNeededTime;
        expect(u.needsKill(t), equals(true));
        
        u.lastActivity += 1;
        expect(u.needsKill(t), equals(false));
      });
      
      test("User, terminate, calls close on websocket", () {
        bool wasClosed = false;
        ws.onClosed = (int status, String reason) {
          wasClosed = true;
          expect(status, equals(1000));
          expect(reason, equals("Leaving"));
        };
        
        u.terminate();
        expect(wasClosed, equals(true));
      });
      
      test("User, connection closed, fires event", () {
        MockUserEventListener l = new MockUserEventListener();
        u.subscribe(l);
        
        bool wasClosed = false;
        l.onConnectionClose = (User user, int status, String reason) {
          expect(user, equals(u));
          expect(status, equals(1000));
          wasClosed = true;
        };
        u.terminate();
        expect(wasClosed, equals(true));
      });
    });
  }
  
  
  
}



