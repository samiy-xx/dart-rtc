part of rtc_client;

class NotImplementedException implements Exception{
  final String msg;
  final Exception original;
  const NotImplementedException([this.msg, this.original]);
  String toString() => msg == null ? "InvalidPacketException" : msg;
}

