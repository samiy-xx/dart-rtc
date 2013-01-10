part of rtc_client;

abstract class SignalingEventListener {
  
}

/**
 * Interface PeerMediaEventListener Extends PeerEventListener
 */
abstract class SignalingConnectionEventListener extends SignalingEventListener {
  void onOpen();
  void onClose();
  void onError();
}
typedef void SignalingConnectionEventListenerType();