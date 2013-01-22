part of rtc_client_tests;

class PacketTests {
  run() {
    group('PacketTests', () {
      BinaryPacketHandler handler;
      
      setUp(() {
        handler = new BinaryPacketHandler();
      });
      
      tearDown(() {
        handler = null;
      });
      
      test("BinaryPacketHandler, When created, is not null", () {
        expect(handler, isNotNull);
      });
      
      test("BinaryPacketHandler, When creating ArrayBufferView, Buffer is not null", () {
        ArrayBufferView view = handler.createBufferView(new ByePacket.With('id'));
        expect(view, isNotNull);
      });
      
      test("BinaryPacketHandler, When creating ArrayBufferView, Buffer has correct length", () {
        Packet p = new ByePacket.With('id');
        ArrayBufferView view = handler.createBufferView(p);
        expect(view.byteLength, equals(PacketFactory.get(p).charCodes.length));
      });
    });
  }
}

