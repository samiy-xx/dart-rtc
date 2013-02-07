part of rtc_common_tests;

class PacketTests {
  run() {
    group('PacketTests', () {
      Packet p;
      final String packetId = "abc";
      final PacketType packetType = PacketType.BYE;
      
      setUp(() {
        p = new ByePacket();
        p.id = packetId; 
      });
      
      tearDown(() {
        p = null;
      });
      
      test("Packet, When created, is not null", () {
        expect(p, isNotNull);
      });
      
      test("Packet, When created, has properties", () {
        expect(p.id, equals(packetId));
        expect(p.packetType, equals(packetType));
        expect(p.toJson() is Map, equals(true));
        expect(p.toJson(), contains('packetType'));
        expect(p.toJson(), contains('id'));
      });
      
    });
  }
}



