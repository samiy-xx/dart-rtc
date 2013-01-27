part of rtc_server_tests;

class ContainerTests {
  BaseContainer c;
  Server s;
  
  run() {  
    group('ContainerTests', () {
      setUp(() {
        s = new TestableServer();
        c = new BaseContainer<String>(s);
      });
      
      tearDown(() {
        c = null;
        s = null;
      });
      
      test("Container, When created, is not null", () {
        expect(c, isNotNull);
      });
      
      test("Container, When created, has properties", () {
        expect(c.server, isNotNull);
        expect(c.server, equals(s));
        expect(c.count, equals(0));
      });
      
      test("Container, getServer method, returns server", () {
        expect(c.getServer(), equals(s));
      });
      
      test("Container, add, can add", () {
        String toAdd = "dart";
        expect(c.count, equals(0));
        expect(c.contains(toAdd), equals(false));
        
        c.add(toAdd);
        expect(c.count, equals(1));
        expect(c.contains(toAdd), equals(true));
      });
      
      test("Container, remove, can remove", () {
        String toAdd = "dart";
        c.add(toAdd);
        expect(c.count, equals(1));
        expect(c.contains(toAdd), equals(true));
        
        c.remove(toAdd);
        expect(c.count, equals(0));
        expect(c.contains(toAdd), equals(false));
      });
      
      test("Container, add, fires event", () {
        String toAdd = "dart";
        MockContainerEventListener l = new MockContainerEventListener();
        c.subscribe(l);
        
        int count = 0;
        bool fired = false;
        
        l.countCallback = (BaseContainer container) {
          expect(container, equals(c));
          fired = true;
          count++;
        };
        c.add(toAdd);
        expect(fired, equals(true));
        expect(count, equals(1));
      });
      
      test("Container, remove, fires event", () {
        String toAdd = "dart";
        MockContainerEventListener l = new MockContainerEventListener();
        c.subscribe(l);
        
        int count = 0;
        bool fired = false;
        
        l.countCallback = (BaseContainer container) {
          expect(container, equals(c));
          fired = true;
          count++;
        };
        
        c.add(toAdd);
        c.remove(toAdd);
        expect(fired, equals(true));
        expect(count, equals(2));
      });
    });
  }
}

