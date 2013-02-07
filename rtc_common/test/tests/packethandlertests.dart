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
        expect(p.getHandlers(PacketType.JOIN), equals(null));
        p.registerHandler(PacketType.JOIN, (Packet p) => p = null);
        expect(p.getHandlers(PacketType.JOIN).length, equals(1));
      });
      
      test("PacketHandler, handlers, can clear given type", () {
        expect(p.getHandlers(PacketType.JOIN), equals(null));
        p.registerHandler(PacketType.JOIN, (Packet p) => p = null);
        expect(p.getHandlers(PacketType.JOIN).length, equals(1));
        p.clearHandlers(PacketType.JOIN);
        expect(p.getHandlers(PacketType.JOIN), equals(null));
      });
      
      test("PacketHandler, handlers, execute", () {
        PacketType type = PacketType.BYE;
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

