import "dart:html";
import '../lib/demo_client.dart';
import '../../rtc_client/lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

void main() {
  Element c = query("#container");
  Notifier notifier = new Notifier();
  WebVideoManager vm = new WebVideoManager();
  vm.setMainContainer("#main");
  vm.setChildContainer("#aux");
  WebVideoContainer vc = vm.addVideoContainer("main_user", "main");
  
  ChannelClient qClient = new ChannelClient(new WebSocketDataSource("ws://127.0.0.1:8234/ws"))
  .setChannel("abc")
  .setRequireAudio(true)
  .setRequireVideo(true)
  .setRequireDataChannel(false);
  
  qClient.onInitializedEvent.listen((InitializedEvent e) => notifier.display(e.message));
  qClient.onSignalingOpenEvent.listen((SignalingOpenEvent e) => notifier.display("Signaling connected to server ${e.message}"));
 
  qClient.onRemoteMediaStreamAvailableEvent.listen((MediaStreamAvailableEvent e) {
    if (e.pw == null) {
      vm.setLocalStream(e.ms);
      vc.setStream(e.ms);
    } else {
      vm.addStream(e.ms, e.pw.id);
    }
  });
  
  qClient.onRemoteMediaStreamRemovedEvent.listen((MediaStreamRemovedEvent e) {
    notifier.display("Remote stream removed");
    vm.removeRemoteStream(e.pw.id);
  });
  
  qClient.onSignalingCloseEvent.listen((SignalingCloseEvent e) {
    notifier.display("Signaling connection to server has closed (${e.message})");
    window.setTimeout(() {
      notifier.display("Attempting to reconnect to server");
      qClient.initialize();
    }, 10000);
  });
  
  qClient.initialize();
}

