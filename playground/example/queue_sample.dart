import "dart:html";
import '../single/demo_client.dart';
import '../../rtc_client/lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

void main() {
  VideoElement localVideo = query("#local_video");
  VideoElement remoteVideo = query("#remote_video");
  Element c = query("#container");
  new LocalQueueManager(c, localVideo, remoteVideo).initialize();
  new Logger().setLevel(LogLevel.INFO);
  new Logger().Error("Test");
  new Logger().Warning("Test");
  new Logger().Info("Test");
  new Logger().Debug("Test");
}

class LocalQueueManager implements PeerMediaEventListener {
  Resizer _local_video_resizer;
  Resizer _remote_video_resizer;
  VideoElement _local_video;
  VideoElement _remote_video;
  Element _container;
  StreamingSignalHandler _sh;
  PeerManager _pm;
  DataSource _ds;
  bool _inQueue = false;
  Notifier _notify;
  
  LocalQueueManager(Element container, Element local, Element remote) {
    _local_video = local;
    _remote_video = remote;
    _container = container;
    _notify = new Notifier();
    _ds = new WebSocketDataSource("ws://127.0.0.1:8234/ws");
    _sh = new StreamingSignalHandler(_ds);
    _pm = new PeerManager();
    _pm.subscribe(this);
    _sh.registerHandler("queue", handleQueue);
    _sh.registerHandler("bye", handleBye);
    
  }
  
  void handleBye(ByePacket bp) {
    _remote_video.pause();
    String a = Util.aspectRatio(_local_video.videoWidth, _local_video.videoHeight);
    int h = Util.getHeight(_container.clientWidth, a);
    _local_video_resizer.setSize(_local_video.videoWidth, h);
    _local_video_resizer.setPosition(0, 0);
    _local_video.style.zIndex = "10";
    _remote_video.style.zIndex = "999";
    _remote_video_resizer.setSize(100, 100);
    _remote_video_resizer.setPosition(10, 10);
  }
  
  void handleQueue(QueuePacket qp) {
    if (!_inQueue) {
      _inQueue = true;
      new Logger().Debug("Entered Queue. Position ${qp.position}");
      _notify.display("Entered Queue. Position ${qp.position}");
    } else {
      if (int.parse(qp.position) > 0) {
        new Logger().Debug("Queue Position ${qp.position}");
        _notify.display("Queue Position ${qp.position}");
      } else {
        new Logger().Debug("Left queue");
        _notify.display("Left queue");
      }
    }
  }
  
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    
  }
  
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool isMain) {
    _remote_video.onLoadedMetadata.listen((Event e) {
      String a = Util.aspectRatio(_remote_video.videoWidth, _remote_video.videoHeight);
      int h = Util.getHeight(_container.clientWidth, a);
      _remote_video_resizer.setPosition(0, 0);
      _remote_video_resizer.setSize(_container.clientWidth, h);
      _remote_video.style.zIndex = "10";
      _local_video.style.zIndex = "999";
      _local_video_resizer.setPosition(10, 10);
      _local_video_resizer.setSize(100, 100);
    });
    _remote_video.onCanPlay.listen((Event e) => _remote_video.play());
    _remote_video.src = Url.createObjectUrl(ms);
  }
  
  void initialize() {
    _local_video_resizer = new Resizer(_local_video, 0, 0, 0, 0);
    _remote_video_resizer = new Resizer(_remote_video, 0, 0, 0, 0);
    
    new Notifier().display("Allow access to web camera!");
    if (MediaStream.supported) {
      window.navigator.getUserMedia(audio: true, video: true).then((LocalMediaStream stream) {
        new Notifier().display("Got access to web camera!");
        new PeerManager().setLocalStream(stream);
        _local_video.onLoadedMetadata.listen((Event e) {
          String a = Util.aspectRatio(_local_video.videoWidth, _local_video.videoHeight);
          int h = Util.getHeight(_container.clientWidth, a);
          _container.style.height = "${h}px";
          _local_video_resizer.setSize(_container.clientWidth, h);
        });
        _local_video.src = Url.createObjectUrl(stream);
        _sh.channelId = "abs";
        _sh.initialize();
      });
    } else {
      Logger log = new Logger();
      log.Error("getUserMedia not supported");
      new Notifier().display("Error: getUserMedia not supported");
    }
  }
}



