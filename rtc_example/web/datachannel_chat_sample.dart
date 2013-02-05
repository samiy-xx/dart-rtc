import "dart:html";
import '../lib/demo_client.dart';
import '../../rtc_client/lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

void main() {
  Element c = query("#container");
  Notifier notifier = new Notifier();
  DivElement chat_output = query("#chat_output");
  DivElement chat_input = query("#chat_input");
  
  ChannelClient qClient = new ChannelClient(new WebSocketDataSource("ws://127.0.0.1:8234/ws"))
  .setChannel("abc")
  .setRequireAudio(false)
  .setRequireVideo(false)
  .setRequireDataChannel(true);
  
  qClient.onInitializedEvent.listen((InitializedEvent e) => notifier.display(e.message));
  qClient.onSignalingOpenEvent.listen((SignalingOpenEvent e) {                                                         
    notifier.display("Signaling connected to server ${e.message}");
    chat_input.contentEditable = "true";
  });
  
}

