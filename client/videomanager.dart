part of rtc_client;

/**
 * Abstract VideoManager
 */
abstract class VideoManager {
  /** Sets the stream to VideoContainer */
  void setStream(MediaStream ms, VideoContainer c);
  
  /** Adds a new VideoContainer */
  VideoContainer addVideoContainer(String id);
  
  /** Removes a video container with id */
  void removeVideoContainer(String id);
}
