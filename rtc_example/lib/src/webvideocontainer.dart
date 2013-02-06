part of demo_client;

class WebVideoContainer extends VideoContainer {
  WebVideoManager _manager;
  VideoElement _video;
  DivElement _div;
  
  String _id;
  String _url;
  String _aspectRatio;
  String get aspectRatio => _aspectRatio;
  Element get matcher => _video;
  VideoElement get video => _video;
  set id(String value) => _id = value;
  String get id => _id;
  const String CSS_HIDDEN = "hidden";
  const String CSS_VISIBLE = "visible";
  Logger log = new Logger();
  /**
   * Constructor
   */
  WebVideoContainer(VideoManager manager, String id) {
    _manager = manager;
    _id = id;
    _video = new VideoElement();
    _div = new DivElement();
    
    _div.nodes.add(_video);
    _video.onCanPlay.listen(_onCanPlay);
    _video.onPlay.listen(_onPlay);
    _video.onPause.listen(_onPause);
    _video.onEnded.listen(_onStop);
    _video.onLoadedMetadata.listen(_onMetadata);
    
    matcher.onClick.listen((e) {
      print(_id);
      
    });
  }
  /* Public methods */
  void initialize([bool aux]) {
    _video.classes.add("vid");
    _video.id = "vid_${_id}";
    if (?aux)
      _video.classes.add("auxvid");
    _video.autoplay = true;
    _video.poster = _manager._poster;
  }
  
  void pause() {
    _video.pause();
  }
  
  void play() {
    _video.play();
  }
  
  void setStream(MediaStream m) {
    _url = Url.createObjectUrl(m);
    setUrl(_url);
  }
  
  void setUrl(String url) {
    _video.src = url;  
  }
  
  void destroy() {
    _video.pause();
    matcher.remove();
  }
  
  //void setOverlay(Overlay o) {
  //  _overlay = o;
  //}
  
  /**
   * Set initial Css properties
   */
  //void _setCssProperties() {
  //  _overlay.style.visibility = CSS_HIDDEN;  
  //}
  
  void _onMetadata(Event e) {
    log.Debug("_onMetadata");
    _aspectRatio = Util.aspectRatio(_video.videoWidth, _video.videoHeight);
    _manager.setProportions(this);
  }
  
  void _onCanPlay(Event e) {
    log.Debug("_onCanPlay");
    _video.play();
  }
  /**
   * Handle play event for video
   */
  void _onPlay(Event e) {
    log.Debug("_onPlay");
  }
  
  /**
   * Handle ended event for video
   */
  void _onStop(Event e) {
    log.Debug("_onStop");
  }
  
  /**
   * Handle pause event for video
   */
  void _onPause(Event e) {
    log.Debug("_onPause");
  }
  
  
}