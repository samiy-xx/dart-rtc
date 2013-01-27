part of rtc_common_tests;

class PacketHandlerTests {
  PacketHandler p;
  
  run() {
    group('PacketHandlerTests', () {
      
      setUp(() {
        p = new PacketHandler();
      });
      
      tearDown(() {
        p = null;
      });
      
      test("PacketHandler, When created, is not null", () {
        expect(p, isNotNull);
      });
      
      test("PacketHandler, handlers, can register", () {
        expect(p.getHandlers("dart"), equals(null));
        p.registerHandler("dart", (Packet p) => p = null);
        expect(p.getHandlers("dart").length, equals(1));
      });
      
      test("PacketHandler, handlers, can clear given type", () {
        expect(p.getHandlers("dart"), equals(null));
        p.registerHandler("dart", (Packet p) => p = null);
        expect(p.getHandlers("dart").length, equals(1));
        p.clearHandlers("dart");
        expect(p.getHandlers("dart"), equals(null));
      });
      
      test("PacketHandler, handlers, execute", () {
        String type = "bye";
        String packetId = "123";
        bool packetWasHandled = false;
        
        p.registerHandler(type, (Packet p)  {
          expect(p.id, equals(packetId));
          expect(p.packetType, equals(PacketType.BYE));
          packetWasHandled = true;
        });
       
        p.executeHandler(new ByePacket.With(packetId));
        
        expect(packetWasHandled, equals(true));
      });
    });
  }
}

