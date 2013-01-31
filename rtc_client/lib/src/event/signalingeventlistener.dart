part of rtc_client;

/**
 * Base Signaling event interface
 */
abstract class SignalingEventListener {
  
}

/**
 * Interface PeerMediaEventListener Extends PeerEventListener
 */
abstract class SignalingConnectionEventListener extends SignalingEventListener {
  /**
   * Signaling has connected to server
   */
  void onOpenSignaling();
  
  /**
   * Connection to the server has been closed
   */
  void onCloseSignaling();
  
  /**
   * Error =)
   */
  void onSignalingError();
}
