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
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool main);
}

/**
 * Interface PeerPacketEventListener Extends PeerEventListener
 */
abstract class PeerPacketEventListener extends PeerEventListener {
  void onPacketToSend(String p);
}

/**
 * Interface PeerDataEventListener Extends PeerEventListener
 */
abstract class PeerDataEventListener extends PeerEventListener {
  void onDataReceived(int buffered);
  void onChannelStateChanged(PeerWrapper p, String state);
}
