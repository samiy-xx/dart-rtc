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
  
  localVideo.onLoadedMetadata.listen((Event e) {
    int h = Util.getHeight(c.clientWidth, Util.aspectRatio(localVideo.videoWidth, localVideo.videoHeight));
    localVideo.width = c.clientWidth;
    localVideo.height = h;
  });
  
  remoteVideo.onLoadedMetadata.listen((Event e) {
    int h = Util.getHeight(c.clientWidth, Util.aspectRatio(remoteVideo.videoWidth, remoteVideo.videoHeight));
    remoteVideo.width = c.clientWidth;
    remoteVideo.height = h;
  });
  
  QueueClient qClient = new QueueClient(new WebSocketDataSource("ws://127.0.0.1:8234/ws"))
  .setChannel("abc")
  .setRequireAudio(true)
  .setRequireVideo(true)
  .setRequireDataChannel(false);
  
  qClient.onInitializedEvent.listen((InitializedEvent e) {
    notifier.display(e.message);
  });
  
  qClient.onRemoteMediaStreamAvailableEvent.listen((MediaStreamAvailableEvent e) {
    if (e.pw == null) {
      remoteVideo.style.display = "none";
      remoteVideo.pause();
      localVideo.src = Url.createObjectUrl(e.ms);
    } else {
      localVideo.pause();
      localVideo.style.display = "none";
      remoteVideo.src = Url.createObjectUrl(e.ms);
    }
  });
  
  qClient.onDataSourceOpenEvent.listen((DataSourceOpenEvent e) {
    notifier.display("DataSource connected ${e.message}");
  });
  
  qClient.onDataSourceCloseEvent.listen((DataSourceCloseEvent e) {
    notifier.display("DataSource connection closed (${e.message})");
    window.setTimeout(() {
      qClient.initialize();
    }, 2000);
  });
  
  qClient.onQueueEvent.listen((QueueEvent e) {
    notifier.display("Queue ${e.position}");
  });
  
  monitor.set(qClient.queued);
  monitor.start();
  qClient.initialize();
  
   
}

// Could really use web_ui ?
class QueueMonitor {
  Element _container;
  List<QueueUser> _items;
  int _loopId;
  
  QueueMonitor(Element e) {
    _container = e;
  }
  
  void set(List<QueueUser> items) {
    _items = items;
  }
  
  void start() {
    if (_items == null)
      return;
    
    _loopId = window.setInterval(update, 1000);
  }
  
  void update() {
    print(_items.length);
    _container.nodes.clear();
    _items.forEach((QueueUser u) {
      addNode(u);
    });
  }
  
  
  bool idExists(Iterable i, String id) {
    return i.any((Element e) => e.id == id);
  }
  
  void addNode(QueueUser u) {
    int now = new DateTime.now().millisecondsSinceEpoch;
    DivElement e = createDiv((now - u.entered.millisecondsSinceEpoch) ~/ 1000, u.id, u.position);
    _container.append(e);
  }
  
  DivElement createDiv(int t, String id, int p) {
    DivElement e = new DivElement();
    e.classes.add("queue_item");
    e.id = id;
    
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

