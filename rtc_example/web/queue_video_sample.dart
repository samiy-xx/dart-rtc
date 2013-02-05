import "dart:html";
import '../lib/demo_client.dart';
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
  
  localVideo.onCanPlay.listen((_) => localVideo.play());
  localVideo.onDoubleClick.listen((_) => localVideo.webkitRequestFullscreen());
  localVideo.onLoadedMetadata.listen((Event e) {
    int h = Util.getHeight(c.clientWidth, Util.aspectRatio(localVideo.videoWidth, localVideo.videoHeight));
    localVideo.width = c.clientWidth;
    localVideo.height = h;
  });
  
  remoteVideo.onCanPlay.listen((_) => remoteVideo.play());
  remoteVideo.onDoubleClick.listen((_) => remoteVideo.webkitRequestFullscreen());
  remoteVideo.onLoadedMetadata.listen((Event e) {
    int h = Util.getHeight(c.clientWidth, Util.aspectRatio(remoteVideo.videoWidth, remoteVideo.videoHeight));
    remoteVideo.width = c.clientWidth;
    remoteVideo.height = h;
  });
  
  qClient.onInitializedEvent.listen((InitializedEvent e) => notifier.display(e.message));
  qClient.onSignalingOpenEvent.listen((SignalingOpenEvent e) => notifier.display("Signaling connected to server ${e.message}"));
  qClient.onQueueEvent.listen((QueueEvent e) => notifier.display("Queue ${e.position}"));
  
  qClient.onRemoteMediaStreamAvailableEvent.listen((MediaStreamAvailableEvent e) {
    if (e.pw == null) {
      notifier.display("Display local stream");
      remoteVideo.style.display = "none";
      remoteVideo.pause();
      localVideo.style.display = "block";
      localVideo.src = Url.createObjectUrl(e.ms);
    } else {
      notifier.display("Display remote stream");
      localVideo.pause();
      localVideo.style.display = "none";
      remoteVideo.src = Url.createObjectUrl(e.ms);
      remoteVideo.style.display = "block";
    }
  });
  
  qClient.onRemoteMediaStreamRemovedEvent.listen((MediaStreamRemovedEvent e) {
    notifier.display("Remote stream removed");
    remoteVideo.style.display = "none";
    remoteVideo.pause();
    
    localVideo.style.display = "block";
    int h = Util.getHeight(c.clientWidth, Util.aspectRatio(localVideo.videoWidth, localVideo.videoHeight));
    localVideo.width = c.clientWidth;
    localVideo.height = h;
    localVideo.play();
  });
  
  qClient.onSignalingCloseEvent.listen((SignalingCloseEvent e) {
    notifier.display("Signaling connection to server has closed (${e.message})");
    window.setTimeout(() {
      notifier.display("Attempting to reconnect to server");
      qClient.initialize();
    }, 10000);
  });
  
  qClient.onPacketEvent.listen((PacketEvent e) {
    if (e.type == PacketType.CHANNEL) {
      ChannelPacket p = e.packet as ChannelPacket;
      
      if (p.owner) {
        var nextButton = new ButtonElement();
        nextButton.appendText("Next!");
        query("#controls").append(nextButton);
        nextButton.onClick.listen((Event e) {
          if (qClient.queued.length > 0) {
            notifier.display("Requesting new user from queue");
            qClient.nextUser();  
          } else {
            notifier.display("Queue is empty");
          }
        });
      }
    }
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

