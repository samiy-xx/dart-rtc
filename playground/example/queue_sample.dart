import "dart:html";
import '../single/demo_client.dart';
import '../../rtc_client/lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

void main() {
  VideoElement localVideo = query("#local_video");
  VideoElement remoteVideo = query("#remote_video");
  Element c = query("#container");
  Notifier notifier = new Notifier();
  QueueMonitor monitor = new QueueMonitor(query("#queue"));
  
  QueueClient qClient = new QueueClient(new WebSocketDataSource("ws://127.0.0.1:8234/ws"))
  .setChannel("abc")
  .setRequireAudio(true)
  .setRequireVideo(true)
  .setRequireDataChannel(false);
  
  qClient.onInitializedEvent.listen((InitializedEvent e) {
    notifier.display(e.message);
  });
  
  qClient.onRemoteMediaStreamAvailableEvent.listen((MediaStreamAvailableEvent e) {
    if (e.pw == null)
      localVideo.src = Url.createObjectUrl(e.ms);
  });
  
  
  qClient.initialize();
  
   
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
  QueueMonitor _monitor;
  
  LocalQueueManager(Element container, Element local, Element remote) {
    _local_video = local;
    _remote_video = remote;
    _container = container;
    _notify = new Notifier();
    _monitor = new QueueMonitor(query("#queue"));
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
    if (_sh.isChannelOwner) {
      QueueItem q = _monitor.find(qp.id);
      if (q == null) {
        _monitor.add(qp.id, int.parse(qp.position));
      } else {
        if (int.parse(qp.position) > 0) {
          _monitor.move(qp.id, int.parse(qp.position));
        } else {
          _monitor.remove(qp.id);
        }
      }   
    } else {
      if (!_inQueue) {
        _inQueue = true;
        _notify.display("Entered Queue. Position ${qp.position}");
        _monitor.add(qp.id, int.parse(qp.position));
      } else {
        if (int.parse(qp.position) > 0) {
          _notify.display("Queue Position ${qp.position}");
          _monitor.move(qp.id, int.parse(qp.position));
        } else {
          _notify.display("Left queue");
          _monitor.remove(qp.id);
        }
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

class QueueItem implements Comparable {
  DateTime _entered;
  String _id;
  int _position;
  
  QueueItem(String id, int p) {
    _id = id;
    _position = p;
    _entered = new DateTime.now();
  }
  
  String toString() {
    return "${_entered.toString()} ${_id} ${_position}";
  }
  
  int compareTo(QueueItem o) {
    if (_position < o._position)
      return -1;
    
    if (_position == o._position)
      return 0;
    
    return 1;
  }
  operator < (QueueItem o) {
    return _position < o._position;
  }
  
  operator <= (QueueItem o) {
    return _position <= o._position;
  }
  
  operator >= (QueueItem o) {
    return _position >= o._position;
  }
  operator > (QueueItem o) {
    return _position > o._position;
  }
}

class QueueMonitor {
  Element _container;
  List<QueueItem> _items;
  
  QueueMonitor(Element e) {
    _container = e;
    _items = new List<QueueItem>();
  }
  
  void add(String id, int p) {
    _items.add(new QueueItem(id ,p));
    sortPack();
    write();
  }
  
  void remove(String id) {
    QueueItem q = find(id);
    if (q != null)
      _items.remove(q);
    sortPack();
    write();
  }
  
  void move(String id, int position) {
    QueueItem q = find(id);
    if (q != null) {
      q._position = position;
      sortPack();
      write();
    }
  }
  
  QueueItem find(String id) {
    for (int i = 0; i < _items.length; i++) {
      QueueItem q = _items[i];
      if (q._id == id)
        return q;
    }
    return null;
  }
  
  void sortPack() {
    _items.sort((a, b) => a.compareTo(b));
  }
  
  void write() {
    _container.nodes.clear();
    _items.forEach((QueueItem q) {
      _container.append(createDiv(q._entered, q._id, q._position));
    });
  }
  
  DivElement createDiv(DateTime t, String id, int p) {
    DivElement e = new DivElement();
    e.classes.add("queue_item");
    
    SpanElement span_time = new SpanElement();
    span_time.appendText(t.toString());
    span_time.classes.add("queue_item_time");
    
    SpanElement span_id = new SpanElement();
    span_id.appendText(id);
    span_id.classes.add("queue_item_id");
    
    SpanElement span_position = new SpanElement();
    span_position.appendText(p.toString());
    span_position.classes.add("queue_item_position");
    
    SpanElement span_action = new SpanElement();
    span_action.appendText("A");
    span_action.classes.add("queue_item_action");
    
    e.append(span_time);
    e.append(span_id);
    e.append(span_position);
    e.append(span_action);
    return e;
  }
}

