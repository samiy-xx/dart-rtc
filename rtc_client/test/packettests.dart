part of rtc_client_tests;

class PacketTests {
  run() {
    group('PacketTests', () {
      String packetId;
      Packet defaultPacket;
      BinaryPacketHandler handler;
      
      setUp(() {
        defaultPacket = new ByePacket.With(packetId);
        handler = new BinaryPacketHandler();
      });
      
      tearDown(() {
        defaultPacket = null;
        handler = null;
      });
      
      test("BinaryPacketHandler, When created, is not null", () {
        expect(handler, isNotNull);
      });
      
      test("BinaryPacketHandler, When creating ArrayBufferView, Buffer is not null", () {
        ArrayBufferView view = handler.createBufferView(defaultPacket);
        expect(view, isNotNull);
      });
      
      test("BinaryPacketHandler, When creating ArrayBufferView, Buffer has correct length", () {
        ArrayBufferView view = handler.createBufferView(defaultPacket);
        expect(view.byteLength, equals(PacketFactory.get(defaultPacket).charCodes.length));
      });
    });
  }
}

