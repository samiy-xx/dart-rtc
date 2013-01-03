import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../client/rtc_client.dart';
import '../packet/packet.dart';

void main() {
  Notifier notify = new Notifier();
  notify.setParent("#container");
  WheelSignalHandler sh = new WheelSignalHandler();
  PeerManager pm = new PeerManager();
  LocalMediaStream ms;
  
  sh.channelId = "123";
  
  
  VideoElement main_vid = query("#main");
  VideoElement aux_vid = query("#aux");
  
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
    aux_vid.src = Url.createObjectUrl(ms);
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
  
  notify.display("Allow access to web camera!");
  window.navigator.webkitGetUserMedia({'video': true, 'audio': true}, (LocalMediaStream stream) {
    ms = stream;
    sh.initialize();
    sh.getPeerManager().setLocalStream(ms);
    main_vid.src = Url.createObjectUrl(stream);
    
    notify.display("Connecting to signaling server...");
    
    main_vid.on.loadedMetadata.add((e) {
      setWidth(main_vid.videoWidth);
      setHeight(main_vid.videoHeight);
    });
    
  }, (e) {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
  });
  
  
}

void setWidth(int w) {
  DivElement container = query("#container");
  DivElement videoContainer = query("#videocontainer");
  DivElement chatContainer = query("#chat");
  print(w);
  container.style.width = "${w}px";
  videoContainer.style.width = "${w}px";
  chatContainer.style.width = "${w}px";
}

void setHeight(int h) {
  DivElement container = query("#container");
  DivElement videoContainer = query("#videocontainer");
  DivElement chatContainer = query("#chat");
  print(h);
  
  container.style.height = "${h}px";
  videoContainer.style.height = "${h}px";
  
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