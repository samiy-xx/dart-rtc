import 'dart:html';

import 'single/demo_client.dart';
import '../rtc_client/lib/rtc_client.dart';
import '../rtc_common/lib/rtc_common.dart';

const int MARGIN = 10;
const int MAX_WIDTH = 800;

class QuickHandler implements PeerMediaEventListener {
  WheelSignalHandler _sh;
  PeerManager _pm;
  VideoElement _local;
  VideoElement _remote;
  VideoElement _current;
  ButtonElement _next;
  ButtonElement _close;
  
  Notifier _notify;
  
  set local(VideoElement e) => _local = e;
  set remote(VideoElement e) => _remote = e;
  set next(ButtonElement e) => setNextButton(e);
  set close(ButtonElement e) => setCloseButton(e);
  
  QuickHandler() {
    _current = _local;
    _notify = new Notifier();
    //_notify.setParent("#videocontainer");
    _sh = new WheelSignalHandler(new WebSocketDataSource("ws://127.0.0.1:8234/ws"));
    _pm = new PeerManager();
    
    _sh.registerHandler("usermessage", handleUserMessage);
    _sh.registerHandler("connected", handleConnected);
    _sh.registerHandler("disconnected", handleDisconnected);
    _sh.registerHandler("bye", handleBye);
    _sh.registerHandler("id", handleId);
    _sh.registerHandler("join", handleJoin);
    
    _pm.subscribe(this);
  }
  
  void setNextButton(ButtonElement e) {
    _next = e;
    _next.on.click.add(nextButtonClicked);
  }
  
  void setCloseButton(ButtonElement e) {
    _close = e;
    _close.on.click.add(closeButtonClicked);
  }
  
  void nextButtonClicked(Event e) {
    _notify.display("Requesting new partner...");
    _pm.closeAll();
    _sh.send(PacketFactory.get(new RandomUserPacket.With(_sh.id)));
    _remote.pause();
    _current = _local;
    resize();
  }
  
  void closeButtonClicked(Event e) {
    _notify.display("Disconnected");
    _pm.closeAll();
    _sh.send(PacketFactory.get(new Disconnected.With(_sh.id)));
    _remote.pause();
    _current = _local;
    resize();
  }
  
  void initialize() {
    _notify.display("Connecting...");
    _sh.initialize();
  }
  
  void close() {
    _sh.close();
  }
  
  void resize() {
    resizeLarge(_current);
    resizeSmall(_current == _remote ? _local : _remote);
    //_notify.setSize();
  }
  
  void resizeLarge(VideoElement e) {
    if (e == null)
      return;
    
    int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
    String aspectRatio;
    if (e != null && e.videoWidth != null && e.videoHeight != null)
      aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
    else
      aspectRatio = "16:9";
    
    e.style.top = "0px";
    e.style.left = "0px";
    e.width = w - (MARGIN * 2);
    e.height = Util.getHeight(w - (MARGIN * 2), aspectRatio);
    e.style.zIndex = "9997";
    query("#container").style.height = "${e.height}px";
    query("#videocontainer").style.height = "${e.height}px";
  }
  
  void resizeSmall(VideoElement e) {
    String aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
    int h = Util.getHeight(MAX_WIDTH ~/ 8, aspectRatio);
    
    e.style.top = "10px";
    e.style.left = "10px";
    e.width = MAX_WIDTH ~/ 8;
    e.height = h;
    e.style.zIndex = "9998";
  }
  
  void setMainVideo(MediaStream ms) {
    new Logger().Debug("Setting local video");
    _local.src = Url.createObjectUrl(ms);
    _local.on.loadedMetadata.add((e) {
      _current = _local;
      resize();
    });
  }
  
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    
  }
  
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool isMain) {
    new Logger().Debug("Incoming video stream");
    _notify.display("Incoming video stream");
    _remote.src = Url.createObjectUrl(ms);
    _remote.on.loadedMetadata.add((e) {
      _current = _remote;
      resize();
    });
  }
  
  void handleUserMessage(UserMessage um) {
    new Logger().Debug("UserMessage");
  }
  
  void handleDisconnected(Disconnected d) {
    new Logger().Debug("User disconnected");
    _notify.display("User disconnected...");
    _remote.pause();
    _current = _local;
    resize();
  }
  
  void handleConnected(ConnectionSuccessPacket csp) {
    new Logger().Debug("Connected to signaling server");
    _notify.display("Connected to signaling server succesfully!");
  }
  
  void handleBye(ByePacket bp) {
    new Logger().Debug("User left");
    _notify.display("User disconnected...");
    _remote.pause();
    _remote.src = null;
    _current = _local;
    resize();
  }
  
  void handleId(IdPacket ip) {
    new Logger().Debug("User idpacket");
    if (ip.id != null && !ip.id.isEmpty) {
      _notify.display("User connected...");
      
    } else {
      _notify.display("No users available.");
    }
  }
  
  void handleJoin(JoinPacket jp) {
    new Logger().Debug("USer joinpacket");
  }
}

void main() {
  QuickHandler q = new QuickHandler();
  q.local = query("#main");
  q.remote = query("#aux");
  q.next = query("#next");
  q.close = query("#close");
  
  window.on.resize.add((e) {
    int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
    int containerWidth = w - (MARGIN * 2);

    query("#container").style.width = "${containerWidth}px";
    query("#videocontainer").style.width = "${containerWidth}px";
    query("#chatcontainer").style.width = "${containerWidth}px";
    
    q.resize();
    
  });
  
  window.on.beforeUnload.add((e) {
    q.close();
  });
 
  new Notifier().display("Allow access to web camera!");
  new Logger().Debug("Requesting access to camerA");
  Constraints constraints = new VideoConstraints();
  
  if (MediaStream.supported) {
    window.navigator.getUserMedia(audio: true, video: true).then((LocalMediaStream stream) {
      q.initialize();
      q.setMainVideo(stream);
      new PeerManager().setLocalStream(stream);
    });
  } else {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
    new Notifier().display("Error: Failed to access camera");
  }
  
  
}

void appendNewMessageLine(String sender, String message) {
  DivElement newLineElement = new DivElement();
  SpanElement senderElement = new SpanElement();
  SpanElement messageElement = new SpanElement();
  
  senderElement.appendText(sender);
  messageElement.appendText(message);
  newLineElement.append(senderElement);
  newLineElement.append(messageElement);
  
  (query("#chatText") as DivElement).append(newLineElement);
}