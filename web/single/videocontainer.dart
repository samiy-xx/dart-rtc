part of demo_client;

abstract class VideoContainer {
  void setStream(MediaStream ms);
  void play();
  void pause();
  void destroy();
  void initialize();
  
  String get id;
  String get aspectRatio;
  Element get matcher;
  VideoElement get video;
}