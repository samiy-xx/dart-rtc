part of rtc_client_tests;

class PacketTests {
  run() {
    group('PacketTests', () {
      String packetId;
      Packet defaultPacket;
      
      setUp(() {
        defaultPacket = new ByePacket.With(packetId);
      });
      
      tearDown(() {
        defaultPacket = null;
      });
      
      
      test("BinaryData, When creating ArrayBuffer, Buffer is not null", () {
        ArrayBuffer buffer = BinaryData.createBuffer(defaultPacket);
        expect(buffer, isNotNull);
      });
      
      test("BinaryData, When creating ArrayBuffer, Buffer has correct length", () {
        ArrayBuffer buffer = BinaryData.createBuffer(defaultPacket);
        expect(buffer.byteLength, equals(PacketFactory.get(defaultPacket).charCodes.length * 2));
      });
      
      test("BinaryData, ArrayBuffer, can get string", () {
        ArrayBuffer buffer = BinaryData.createBuffer(defaultPacket);
        String s = BinaryData.stringFromBuffer(buffer);
        Packet p = PacketFactory.getPacketFromString(s);
        expect(s.length, equals(PacketFactory.get(defaultPacket).length));
      });
      /*
      test("BinaryData, test, test", () {
        ArrayBuffer buffer = BinaryData.write(defaultPacket);
        DataView dv = new DataView(buffer);
        expect(dv.getUint8(0), equals(0xFF));
        expect(dv.getUint8(1), equals(PacketFactory.get(defaultPacket).length));
      });
      
      test("BinaryData, test2, test2", () {
        ArrayBuffer buffer = BinaryData.write(defaultPacket);
        DataView dv = new DataView(buffer);
        
        expect(dv.getUint8(0), equals(0xFF));
        expect(dv.getUint8(1), equals(PacketFactory.get(defaultPacket).length));
        
        
        int size = dv.getUint8(1);
        //print(size);
        Uint8Array tmp = new Uint8Array(size);
        for (int i = 0; i < size; i++) {
          tmp[i] = dv.getUint8(i + 2);
        }
        
        //print(tmp.length);
        print(new String.fromCharCodes(tmp.toList()));
        BinaryData.send(defaultPacket);
        //xpect(new String.fromCharCodes(tmp.toList()), equals("a"));
        //view.
        //ArrayBuffer tmp = buffer.slice(4, view[2]);
        //expect(new String.fromCharCodes(new Uint16Array.fromBuffer(tmp).toList()), equals("a"));
        //expect(tmp.byteLength, equals(PacketFactory.get(defaultPacket).length * 2));
      });*/
    });
  }
}

