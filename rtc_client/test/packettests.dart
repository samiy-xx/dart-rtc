part of rtc_client_tests;

class PacketTests {
  run() {
    group('PacketTests', () {
      ArrayBufferView view;
      
      setUp(() {
        view =  new Uint8Array.fromList(['a', 'b', 'c', 'd']);
      });
      
      tearDown(() {
        view = null;
      });
      
      test("View, When created, is not null", () {
        expect(view, isNotNull);
      });
      
      
      
    });
  }
}

