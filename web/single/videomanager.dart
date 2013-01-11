part of demo_client;

/**
 * Abstract VideoManager
 */
abstract class VideoManager {
  /** Sets the stream to VideoContainer */
  void setStream(MediaStream ms, VideoContainer c);
  void addStream(MediaStream ms, String id, [bool main]);
  void addRemoteStream(MediaStream ms, String id, [bool main]);
  /** Adds a new VideoContainer */
  VideoContainer addVideoContainer(String id);
  
  /** Removes a video container with id */
  void removeVideoContainer(VideoContainer vc);
  MediaStream getLocalStream();
  
}
