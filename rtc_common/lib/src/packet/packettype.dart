part of rtc_common;

class PacketType {
  static final String HELO = "helo";
  static final String DESC = "desc";
  static final String ICE = "ice";
  static final String ROOM = "room";
  static final String USER = "user";
  static final String BYE = "bye";
  static final String JOIN = "join";
  static final String ID = "id";
  static final String ACK = "ack";
  static final String PING = "ping";
  static final String PONG = "pong";
  static final String ROUTE = "route";
  static final String CONNECTED = "connected";
  static final String RANDOM = "random";
  static final String DISCONNECTED = "disconnected";
  static final String QUEUE = "queue";
  static final String FILE = "file";
}

class PacketType2 {
  static final PacketType2 HELO = const PacketType2("helo");
  static final PacketType2 DESC = const PacketType2("desc");
  static final PacketType2 ICE = const PacketType2("ice");
  static final PacketType2 BYE = const PacketType2("bye");
  static final PacketType2 JOIN = const PacketType2("join");
  static final PacketType2 ID = const PacketType2("id");
  static final PacketType2 ACK = const PacketType2("ack");
  static final PacketType2 PING = const PacketType2("ping");
  static final PacketType2 PONG = const PacketType2("pong");
  final String type;
  const PacketType2(this.type);
  String toString() => type;
}