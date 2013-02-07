part of rtc_client;

/**
 * Base interface for the clients exposed by the api 
 */
abstract class RtcClient {
  /**
   * Initializes the connection
   */
  void initialize();
  
  /**
   * If you set this true, some sort of microphone is required
   */
  RtcClient setRequireAudio(bool b);
  
  /**
   * Webcam or software that emulates video source required if this is true
   */
  RtcClient setRequireVideo(bool b);
  
  /**
   * Enables datachannel
   */
  RtcClient setRequireDataChannel(bool b);
  
  /**
   * Channel name. Users join a channel on the server
   */
  RtcClient setChannel(String c);
  
  /**
   * Sends a message that goes trough the server to all users in channel
   */
  void sendChannelMessage(String message);
  
  /**
   * Sends a string trough peer connection
   */
  void sendPeerUserMessage(String peerId, String message);
  
  /**
   * Sends a packet trough peer connection
   */
  void sendPeerPacket(String peerId, Packet p);
}