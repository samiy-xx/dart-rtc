part of rtc_client_tests;

class BinaryWriterTests {
  String packetId;
  Packet defaultPacket;
  BinaryDataWriter writer;
  
  final int STRING_HEADER_BYTES = 4;
  final int PACKET_HEADER_BYTES = 3;
  final int FILE_HEADER_BYTES = 6;
  
  run() {
    group('BinaryWriterTests', () {
      
      setUp(() {
        defaultPacket = new ByePacket.With(packetId);
        writer = new BinaryDataWriter();  
      });
      
      tearDown(() {
        defaultPacket = null; 
        writer = null;
      });
      
      test("BinaryDataWriter, writer, can create header", () {
        int length = 10;
        ArrayBuffer stringHeader = writer.createHeaderFor(BinaryDataType.STRING, length);
        ArrayBuffer packetHeader = writer.createHeaderFor(BinaryDataType.PACKET, length);
        ArrayBuffer fileHeader = writer.createHeaderFor(BinaryDataType.FILE, length);
        
        DataView stringView = new DataView(stringHeader);
        DataView packetView = new DataView(packetHeader);
        DataView fileView = new DataView(fileHeader);
        
        expect(stringView.byteLength, equals(4));
        expect(stringView.getUint8(0), equals(0xFF));
        expect(stringView.getUint8(1), equals(BinaryDataType.STRING.toInt()));
        expect(stringView.getUint16(2), equals(length));
        
        expect(packetView.byteLength, equals(3));
        expect(packetView.getUint8(0), equals(0xFF));
        expect(packetView.getUint8(1), equals(BinaryDataType.PACKET.toInt()));
        expect(packetView.getUint8(2), equals(length));
        
        expect(fileView.byteLength, equals(6));
        expect(fileView.getUint8(0), equals(0xFF));
        expect(fileView.getUint8(1), equals(BinaryDataType.FILE.toInt()));
        expect(fileView.getUint32(2), equals(length));
        
      });
      
      test("BinaryDataWriter, writer, can create footer", () {
        ArrayBuffer stringFooter = writer.createFooterFor(BinaryDataType.STRING);
        ArrayBuffer packetFooter = writer.createFooterFor(BinaryDataType.PACKET);
        ArrayBuffer fileFooter = writer.createFooterFor(BinaryDataType.FILE);
        
        DataView stringView = new DataView(stringFooter);
        DataView packetView = new DataView(packetFooter);
        DataView fileView = new DataView(fileFooter);
        
        expect(stringView.byteLength, equals(3));
        expect(stringView.getUint8(0), equals(0x00));
        expect(stringView.getUint8(1), equals(BinaryDataType.STRING.toInt()));
        expect(stringView.getUint8(2), equals(0x00));
        
        expect(packetView.byteLength, equals(3));
        expect(packetView.getUint8(0), equals(0x00));
        expect(packetView.getUint8(1), equals(BinaryDataType.PACKET.toInt()));
        expect(packetView.getUint8(2), equals(0x00));
        
        expect(fileView.byteLength, equals(3));
        expect(fileView.getUint8(0), equals(0x00));
        expect(fileView.getUint8(1), equals(BinaryDataType.FILE.toInt()));
        expect(fileView.getUint8(2), equals(0x00));
      });
      
      test("BinaryDataWriter, ArrayBuffer, can merge footer", () {
        ArrayBuffer buffer = writer.createPacketBuffer(defaultPacket);
        ArrayBuffer result = writer.mergeFooterTo(buffer, BinaryDataType.PACKET);
        
        expect(buffer, isNotNull);
        expect(result, isNotNull);
        
        DataView dv = new DataView(result);
        
        expect(dv.getUint8(dv.byteLength - 3), equals(0x00));
        expect(dv.getUint8(dv.byteLength -2), equals(BinaryDataType.PACKET.toInt()));
        expect(dv.getUint8(dv.byteLength -1), equals(0x00));
      });
      
      test("BinaryDataWriter, ArrayBuffer, can merge packet header", () {
        int packetLength = PacketFactory.get(defaultPacket).length;
        
        ArrayBuffer buffer = writer.createPacketBuffer(defaultPacket);
        ArrayBuffer result = writer.mergeHeaderTo(buffer, BinaryDataType.PACKET);
        
        expect(buffer, isNotNull);
        expect(result, isNotNull);
        
        DataView dv = new DataView(result);
        expect(dv.byteLength, equals(packetLength + PACKET_HEADER_BYTES));
        expect(dv.getUint8(0), equals(0xFF));
        expect(dv.getUint8(1), equals(BinaryDataType.PACKET.toInt()));
        expect(dv.getUint8(2), equals(packetLength));
      });
      
    });
  }
}

