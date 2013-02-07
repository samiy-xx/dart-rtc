part of rtc_client;

/**
 * Base PeerEventLister interface
 */
abstract class PeerEventListener {
}

/**
 * Interface for peer connection related notifications
 */
abstract class PeerConnectionEventListener extends PeerEventListener {
  void onPeerCreated(PeerWrapper pw);
  /**
   * Notifies listeners that peer state has changed
   */
  void onPeerStateChanged(PeerWrapper pw, String state);
  
  /**
   * Notifies listeners about ice state changes
   */
  void onIceGatheringStateChanged(PeerWrapper pw, String state);
}

/**
 * Interface for peer media stream related notifications
 */
abstract class PeerMediaEventListener extends PeerEventListener {
  /**
   * Remote media stream available from peer
   */
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool main);
  
  /**
   * Media stream was removed
   */
  void onRemoteMediaStreamRemoved(PeerWrapper pw);
}

/**
 * Interface for peer packet (datasource) related notifications 
 */
abstract class PeerPacketEventListener extends PeerEventListener {
  /**
   * Packet needs to be sent
   */
  void onPacketToSend(String p);
}

/**
 * Interface for DataChannel related stuff
 */
abstract class PeerDataEventListener extends PeerEventListener {
  /**
   * Data received from data channel
   */
  void onDataReceived(int buffered);
  
  /**
   * Channel state changed
   */
  void onChannelStateChanged(DataPeerWrapper p, String state);
  
  /**
   * Packet arrived trough data channel
   */
  void onPacket(DataPeerWrapper pw, Packet p);
  
}
