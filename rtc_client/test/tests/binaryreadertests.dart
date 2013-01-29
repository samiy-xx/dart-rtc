part of rtc_client_tests;

class BinaryReaderTests {
  String packetId;
  Packet defaultPacket;
  BinaryDataWriter writer;
  BinaryDataReader reader;
  
  final int STRING_HEADER_BYTES = 4;
  final int PACKET_HEADER_BYTES = 3;
  final int FILE_HEADER_BYTES = 6;
  
  run() {
    group('BinaryReaderTests', () {
      
      setUp(() {
        defaultPacket = new ByePacket.With(packetId);
        writer = new BinaryDataWriter();
        reader = new BinaryDataReader();
      });
      
      tearDown(() {
        defaultPacket = null; 
        writer = null;
        reader = null;
      });
      
      
      test("BinaryDataReader, Read, can merge and read packet", () {
        ArrayBuffer buf = writer.createPacketBuffer(defaultPacket);
        ArrayBuffer result = writer.mergeFooterTo(writer.mergeHeaderTo(buf, BinaryDataType.PACKET),BinaryDataType.PACKET);
        
        bool gotPacket = false;
        bool gotChunk = false;
        BinaryEventListener l = new BinaryEventListener();
        reader.subscribe(l);
        
        l.packetCallback = (Packet p) {
          expect(p.packetType, equals(defaultPacket.packetType));
          expect(p.id, equals(defaultPacket.id));
          gotPacket = true;
        };
        
        l.chunkCallback = (int read, int left) {
          gotChunk = true;
        };
        
        reader.readChunk(result);
        expect(gotPacket, equals(true));
        expect(gotChunk, equals(true));
      });
      
      test("BinaryDataReader, Read, header, content and footer in different chunks", () {
        int length = PacketFactory.get(defaultPacket).length;
        ArrayBuffer buf = writer.createPacketBuffer(defaultPacket);
        ArrayBuffer header = writer.createHeaderFor(BinaryDataType.PACKET, length);
        ArrayBuffer footer = writer.createFooterFor(BinaryDataType.PACKET);
        BinaryEventListener l = new BinaryEventListener();
        reader.subscribe(l);
        int chunks = 0;
        bool gotPacket = false;
        
        l.chunkCallback = (int read, int left) {
          chunks++;
        };
        
        l.packetCallback = (Packet p) {
          expect(p.packetType, equals(defaultPacket.packetType));
          expect(p.id, equals(defaultPacket.id));
          gotPacket = true;
        };
        
        reader.readChunk(header);
        reader.readChunk(buf);
        reader.readChunk(footer);
        
        
        expect(gotPacket, equals(true));
        expect(chunks, equals(3));
      });
      
      test("BinaryDataReader, Read, header, content sliced and footer in different chunks", () {
        int length = PacketFactory.get(defaultPacket).length;
        ArrayBuffer buf = writer.createPacketBuffer(defaultPacket);
        ArrayBuffer header = writer.createHeaderFor(BinaryDataType.PACKET, length);
        ArrayBuffer footer = writer.createFooterFor(BinaryDataType.PACKET);
        
        // Something fishy here with start and end?
        ArrayBuffer chunkBuffer1 = buf.slice(0, 10);
        ArrayBuffer chunkBuffer2 = buf.slice(10, 20);
        ArrayBuffer chunkBuffer3 = buf.slice(20);
        
        BinaryEventListener l = new BinaryEventListener();
        reader.subscribe(l);
        int chunks = 0;
        bool gotPacket = false;
        
        l.chunkCallback = (int read, int left) {
          chunks++;
        };
        
        l.packetCallback = (Packet p) {
          expect(p.packetType, equals(defaultPacket.packetType));
          expect(p.id, equals(defaultPacket.id));
          gotPacket = true;
        };
        
        reader.readChunk(header);
        reader.readChunk(chunkBuffer1);
        reader.readChunk(chunkBuffer2);
        reader.readChunk(chunkBuffer3);
        reader.readChunk(footer);
        
        expect(gotPacket, equals(true));
        expect(chunks, equals(5));
      });
    });
  }
}

