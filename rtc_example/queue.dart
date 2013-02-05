import 'dart:html';

import 'single/demo_client.dart';
import '../rtc_client/lib/rtc_client.dart';
import '../rtc_common/lib/rtc_common.dart';

void main() {
  
  WebVideoManager vm = new WebVideoManager();
  WebChannelHandler handler = new WebChannelHandler(vm);
 
  Constraints constraints = new VideoConstraints();
  vm.setMainContainer("#main");
  vm.setChildContainer("#aux");
  WebVideoContainer vc = vm.addVideoContainer("main_user", "main");
 
  new Notifier().display("Allow access to web camera!");
  
  if (MediaStream.supported) {
    window.navigator.getUserMedia(audio: true, video: true).then((LocalMediaStream stream) {
    //q.initialize();
    //q.setMainVideo(stream);
    //new PeerManager().setLocalStream(stream);
    new Notifier().display("Got access to web camera!");
    vm.setLocalStream(stream);
    vc.setStream(stream);
    new PeerManager().setLocalStream(stream);
    handler.initialize();
    });
  } else {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
    new Notifier().display("Error: Failed to access camera");
  }
  
}

class WebChannelHandler implements PeerMediaEventListener {
  Notifier _notify;
  WebSignalHandler _sh;
  PeerManager _pm;
  WebVideoManager _vm;
  bool _inQueue = false;
  
  WebChannelHandler(WebVideoManager vm) {
    _vm = vm;
    _notify = new Notifier();
    _sh = new WebSignalHandler(new WebSocketDataSource("ws://127.0.0.1:8234/ws"));
    _sh.channelId = "abc";
    _pm = new PeerManager();
    
    _sh.registerHandler("usermessage", handleUserMessage);
    _sh.registerHandler("connected", handleConnected);
    _sh.registerHandler("disconnected", handleDisconnected);
    _sh.registerHandler("bye", handleBye);
    _sh.registerHandler("id", handleId);
    _sh.registerHandler("join", handleJoin);
    _sh.registerHandler("queue", handleQueue);
    
    _pm.subscribe(this);
  }
  
  void initialize() {
    _sh.initialize();
  }
  
  
  void onRemoteMediaStreamRemoved(PeerWrapper pw) {
    
  }
  void onRemoteMediaStreamAvailable(MediaStream ms, PeerWrapper pw, bool isMain) {
    new Logger().Debug("Incoming video stream");
    _notify.display("Incoming video stream");
    _vm.addStream(ms, pw.id);
  }
  
  void handleUserMessage(UserMessage um) {
    new Logger().Debug("UserMessage");
  }
  
  void handleDisconnected(Disconnected d) {
    new Logger().Debug("User disconnected");
    _notify.display("User disconnected...");
    _vm.removeRemoteStream(d.id);
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
    
    new Logger().Debug("Queue position ${qp.position}");
    _notify.display("Connected to signaling server succesfully!");
  }
  
  void handleConnected(ConnectionSuccessPacket csp) {
    new Logger().Debug("Connected to signaling server");
    _notify.display("Connected to signaling server succesfully!");
  }
  
  void handleBye(ByePacket bp) {
    new Logger().Debug("User left");
    _notify.display("User disconnected...");
    _vm.removeRemoteStream(bp.id);
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
    new Logger().Debug("User joinpacket");
  }
}