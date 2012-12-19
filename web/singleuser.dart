import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../packet/packet.dart';

void main() {
  
  WebVideoManager vm = new WebVideoManager();
  WebSignalHandler sh = new WebSignalHandler(vm);
  sh.channelId = "123";
  
  // This is where the your local video stream goes initially
  DivElement main = query("#main");
  
  // And here goes stream(s) that is(are) not assigned to the main slot
  DivElement aux = query("#aux");
  
  ButtonElement be = query("#chatSubmit");
  InputElement chatInput = query("#chatTextToEnter");
  DivElement chatTextContainer = query("#chatText");
  
  be.on.click.add((_) {
     sh.sendMessage("123", chatInput.value);
     chatInput.value = "";
  });
  
  String host = "ws://127.0.0.1:8234/ws";
  sh.initialize(host);
  
  window.on.beforeUnload.add((e) {
    sh.close();
    sh = null;
  });
  
  sh.registerHandler("usermessage", (UserMessage m) {
      appendNewMessageLine(m.id, m.message);
  });
  
  sh.registerHandler("connected", (ConnectionSuccessPacket p) {
    print ("packet");
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