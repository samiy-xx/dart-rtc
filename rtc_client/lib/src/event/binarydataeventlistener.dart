part of rtc_client;

/**
 * Interface for Binary data events
 */
abstract class BinaryDataEventListener {
  
}

/**
 * Interface for received binary data events
 */
abstract class BinaryDataReceivedEventListener extends BinaryDataEventListener {
  void onPacket(Packet p);
  void onReadChunk(int read);
}

/**
 * Interface for sent binary data events
 */
abstract class BinaryDataSentEventListener extends BinaryDataEventListener {
  void onWriteChunk(int wrote);
}