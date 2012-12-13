part of signaling_packets;

class InvalidPacketException implements Exception{
  final String msg;
  final Exception original;
  const InvalidPacketException([this.msg, this.original]);
  String toString() => msg == null ? "InvalidPacketException" : msg;
}
