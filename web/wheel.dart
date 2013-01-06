import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../client/rtc_client.dart';
import '../packet/packet.dart';

const int MARGIN = 10;
const int MAX_WIDTH = 800;
 
class QuickHandler implements PeerMediaEventListener {
  WheelSignalHandler _sh;
  PeerManager _pm;
  VideoElement _local;
  VideoElement _remote;
  VideoElement _current;
  ButtonElement _next;
  
  Notifier _notify;
  
  set local(VideoElement e) => _local = e;
  set remote(VideoElement e) => _remote = e;
  set next(ButtonElement e) => setNextButton(e);
  
  QuickHandler() {
    _current = _local;
    _notify = new Notifier();
    _notify.setParent("#videocontainer");
    _sh = new WheelSignalHandler();
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
  
  void nextButtonClicked(Event e) {
    _pm.closeAll();
    _sh.send(PacketFactory.get(new RandomUserPacket.With(_sh.id)));
    _remote.pause();
    _remote.src = null;
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
  }
  
  void resizeLarge(VideoElement e) {
    int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
    String aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
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
  
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool isMain) {
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
    _remote.src = null;
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
  
  window.navigator.webkitGetUserMedia({'video': true, 'audio': true}, (LocalMediaStream stream) {
    q.initialize();
    q.setMainVideo(stream);
    new PeerManager().setLocalStream(stream); 
  }, (e) {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
  });
  
  
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