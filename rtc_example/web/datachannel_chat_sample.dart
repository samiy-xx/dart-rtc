import "dart:html";
import '../lib/demo_client.dart';
import '../../rtc_client/lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

void main() {
  Element c = query("#container");
  Notifier notifier = new Notifier();
  DivElement chat_output = query("#chat_output");
  DivElement chat_input = query("#chat_input");
  DivElement chat_users = query("#chat_users");
  
  final int KEY_ENTER = 13;
  
  ChannelClient qClient = new ChannelClient(new WebSocketDataSource("ws://127.0.0.1:8234/ws"))
  .setChannel("abc")
  .setRequireAudio(false)
  .setRequireVideo(false)
  .setRequireDataChannel(true);
  
  chat_input.onKeyUp.listen((KeyboardEvent e) {
    if (e.keyCode == KEY_ENTER) {
      
      var entry = createChatEntry(new DateTime.now().toString(), "ME", chat_input.text);
      chat_output.append(entry);
      chat_output.scrollTop = chat_output.scrollHeight;
      
      if (chat_input.text.startsWith("/")) {
        List<String> l = chat_input.text.split(" ");
        String target = l[1];
        List<String> remains = l.getRange(2, l.length - 2);
        qClient.sendPeerUserMessage(target, remains.join(" "));
      } else {
        qClient.sendChannelMessage(chat_input.text);
      }
      
      chat_input.text = "";
      return;
    }
  });
  
  qClient.onInitializedEvent.listen((InitializedEvent e) => notifier.display(e.message));
  qClient.onSignalingOpenEvent.listen((SignalingOpenEvent e) {                                                         
    notifier.display("Signaling connected to server ${e.message}");
    chat_input.contentEditable = "true";
    chat_input.classes.remove("input_inactive");
    chat_input.classes.add("input_active");
    var entry = createChatEntry(new DateTime.now().toString(), "SYSTEM", "Connected to server");
    chat_output.append(entry);
    chat_output.scrollTop = chat_output.scrollHeight;
  });
  
  qClient.onSignalingCloseEvent.listen((SignalingCloseEvent e) {
    notifier.display("Signaling connection to server has closed (${e.message})");
    chat_input.classes.remove("input_active");
    chat_input.classes.add("input_inactive");
    chat_input.contentEditable = "false";
    chat_users.nodes.clear();
    var entry = createChatEntry(new DateTime.now().toString(), "SYSTEM", "Disconnected from server");
    chat_output.append(entry);
    chat_output.scrollTop = chat_output.scrollHeight;
    window.setTimeout(() {
      notifier.display("Attempting to reconnect to server");
      qClient.initialize();
    }, 10000);
  });
  
  qClient.onPacketEvent.listen((PacketEvent e) {
    
    if (e.type == PacketType.CHANNELMESSAGE) {
      ChannelMessage cm = e.packet as ChannelMessage;
      var entry = createChatEntry(new DateTime.now().toString(), cm.id, cm.message);
      chat_output.append(entry);
      chat_output.scrollTop = chat_output.scrollHeight;
    } else if (e.type == PacketType.CHANNEL) {
      ChannelPacket cp = e.packet as ChannelPacket;
      var entry = createChatEntry(new DateTime.now().toString(), "CHANNEL", "Welcome to channel ${cp.channelId}. Channel has ${cp.users} users and has a limit of ${cp.limit} concurrent users");
      chat_output.append(entry);
    } else if (e.type == PacketType.USERMESSAGE) {
      UserMessage um = e.packet as UserMessage;
      var entry = createPrivateEntry(new DateTime.now().toString(), um.id, um.message);
      chat_output.append(entry);
      chat_output.scrollTop = chat_output.scrollHeight;
      notifier.display("Private peer message from ${um.id}");
    } else if (e.type == PacketType.ID) {
      
      IdPacket id = e.packet as IdPacket;
      DivElement u = createUserEntry(id.id);
      chat_users.append(u);
      
      u.onDoubleClick.listen((MouseEvent e) {
        if (chat_input.text == "") {
          chat_input.text = "/msg ${u.id}";
        }
      });
    } else if (e.type == PacketType.JOIN) {
      
      JoinPacket join = e.packet as JoinPacket;
      DivElement u = createUserEntry(join.id);
      chat_users.append(u);
      var entry = createChatEntry(new DateTime.now().toString(), "SYSTEM", "${join.id} joins the channel");
      chat_output.append(entry);
      u.onDoubleClick.listen((MouseEvent e) {
        if (chat_input.text == "") {
          chat_input.text = "/msg ${u.id}";
        }
      });
    } else if (e.type == PacketType.BYE) {
      ByePacket bye = e.packet as ByePacket;
      removeUserEntry(chat_users, bye.id);
      var entry = createChatEntry(new DateTime.now().toString(), "SYSTEM", "${bye.id} leaves the channel");
      chat_output.append(entry);
    }
  });
  qClient.initialize(); 
}

DivElement createChatEntry(String time, String id, String message) {
  DivElement entry = new DivElement();
  entry.classes.add("output_entry");
  
  var span_time = new SpanElement();
  span_time.classes.add("timestamp");
  span_time.appendText(time);
  
  var span_name = new SpanElement();
  span_name.classes.add("name");
  span_name.appendText("< $id >");
  
  var span_message = new SpanElement();
  span_message.classes.add("message");
  span_message.appendText(message);
  
  entry.append(span_time);
  entry.append(span_name);
  entry.append(span_message);
  
  return entry;
}
DivElement createPrivateEntry(String time, String id, String message) {
  DivElement entry = new DivElement();
  entry.classes.add("output_entry");
  entry.classes.add("private_message");
  var span_time = new SpanElement();
  span_time.classes.add("timestamp");
  span_time.appendText(time);
  
  var span_name = new SpanElement();
  span_name.classes.add("name");
  span_name.appendText("(PM)< $id >");
  
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

DivElement createUserEntry(String id) {
  DivElement user = new DivElement();
  user.classes.add("user_entry");
  user.id = id;
  user.appendText(id);
  user.style.cursor = "pointer";
  return user;
}

void removeUserEntry(DivElement e, String id) {
  for (int i = 0; i < e.nodes.length; i++) {
    Element element = e.nodes[i];
    if (element.id == id)
      e.nodes.removeAt(i);
  }
}
