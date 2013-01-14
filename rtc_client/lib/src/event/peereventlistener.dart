part of rtc_client;

/**
 * Base PeerEventLister interface
 */
abstract class PeerEventListener {
}

/**
 * Interface PeerMediaEventListener Extends PeerEventListener
 */
abstract class PeerMediaEventListener extends PeerEventListener {
  /**
   * Remote media stream available from peer
   */
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool main);
}

/**
 * Interface PeerPacketEventListener Extends PeerEventListener
 */
abstract class PeerPacketEventListener extends PeerEventListener {
  /**
   * Packet needs to be sent
   */
  void onPacketToSend(String p);
}

/**
 * Interface PeerDataEventListener Extends PeerEventListener
 * DataChannel related stuff
 */
abstract class PeerDataEventListener extends PeerEventListener {
  /**
   * Data received from data channel
   */
  void onDataReceived(int buffered);
  
  /**
   * Channel state changed
   */
  void onChannelStateChanged(PeerWrapper p, String state);
}
