import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../client/rtc_client.dart';
import '../packet/packet.dart';

void main() {
  Notifier notify = new Notifier();
  WheelSignalHandler sh = new WheelSignalHandler();
  PeerManager pm = new PeerManager();
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
     appendNewMessageLine("ME", chatInput.value);
     chatInput.value = ""; 
  });
  
  pm.subscribe((MediaStream ms, String id, bool isMain) {
    notify.display("Incoming video stream");
  });
  
  window.on.beforeUnload.add((e) {
    sh.close();
    sh = null;
  });
  
  sh.registerHandler("usermessage", (UserMessage m) {
      appendNewMessageLine(m.id, m.message);
  });
  
  sh.registerHandler("connected", (ConnectionSuccessPacket p) {
    notify.display("Connected to signaling server succesfully!");
    notify.display("Requesting random user...", () {
      sh.requestRandomUser();
    });
    
  });
  
  sh.registerHandler("disconnected", (Disconnected p) {
    notify.display("User disconnected...");
  });
  
  sh.registerHandler("id", (IdPacket p) {
    notify.display("User connected...");
  });
  
  sh.initialize();
  notify.display("Connecting to signaling server...");
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