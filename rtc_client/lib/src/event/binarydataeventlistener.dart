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
  void onString(String s);
  void onReadChunk(int read, int leftToRead);
}

/**
 * Interface for sent binary data events
 */
abstract class BinaryDataSentEventListener extends BinaryDataEventListener {
  void onWriteChunk(int wrote);
}

abstract class BinaryBlobReadEventListener extends BinaryDataEventListener {
  void onProgress();
  void onLoadDone(ArrayBuffer b);
}