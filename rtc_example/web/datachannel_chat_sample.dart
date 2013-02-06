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
  
  qClient.onSignalingCloseEvent.listen((SignalingCloseEvent e) {
    notifier.display("Signaling connection to server has closed (${e.message})");
    window.setTimeout(() {
      notifier.display("Attempting to reconnect to server");
      qClient.initialize();
    }, 10000);
  });
  
  qClient.onPacketEvent.listen((PacketEvent e) {
    if (e.type == "usermessage") {
      
    }
  });
  
}

DivElement createChatEntry(String time, String id, String message) {
  DivElement entry = new DivElement();
  entry.classes.add("output_entry");
  
  var span_time = new SpanElement();
  span_time.classes.add("timestamp");
  span_time.appendText(time);
  
  var span_name = new SpanElement();
  span_name.classes.add("name");
  span_name.appendText(id);
  
  var span_message = new SpanElement();
  span_message.classes.add("message");
  span_message.appendText(message);
  
  entry.append(span_time);
  entry.append(span_name);
  entry.append(span_message);
  
  return entry;
}

void pruneEntries() {
  
}

void createUserEntry(String id) {
  
}

void removeUserEntry(String id) {
  
}
