part of rtc_common_tests;

class EventTests {
  GenericEventTarget<MockEventListener> target;
  MockMockEventListener l;
  
  run() {
    group('GenericEventTargetTests', () {
      
      setUp(() {
       target = new GenericEventTarget<MockEventListener>();
       l = new MockMockEventListener();
      });
      
      tearDown(() {
        target = null;
        l = null;
      });
      
      test("GenericEventTarget, When created, is not null", () {
        expect(target, isNotNull);
      });
      
      test("GenericEventTarget, When created, has properties", () {
        expect(target.listeners.length, equals(0));
      });
      
      test("GenericEventTarget, when subscribing to event, getListeners return listeners", () {
        target.subscribe(l);
        expect(target.getListeners().length, equals(1));
        expect(target.getListeners().contains(l), equals(true));
      });
      
      test("GenericEventTarget, when subscribing to event, object added to list", () {
        target.subscribe(l);
        expect(target.listeners.length, equals(1));
        expect(target.listeners.contains(l), equals(true));
      });
      
      test("GenericEventTarget, when unsubscribing from event, object removed from list", () {
        target.subscribe(l);
        expect(target.listeners.length, equals(1));
        expect(target.listeners.contains(l), equals(true));
        target.unsubscribe(l);
        expect(target.listeners.length, equals(0));
        expect(target.listeners.contains(l), equals(false));
      });
      
    });
  }
}

