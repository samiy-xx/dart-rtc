import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../client/rtc_client.dart';
import '../packet/packet.dart';

const int MARGIN = 10;
const int MAX_WIDTH = 800;

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
  
  window.on.resize.add((e) {
    resize();
  });
  
  be.on.click.add((_) {
     sh.sendMessage("123", chatInput.value);
     appendNewMessageLine("ME", chatInput.value);
     chatInput.value = ""; 
  });
  
  pm.subscribe((MediaStream ms, String id, bool isMain) {
    notify.display("Incoming video stream");
    aux_vid.src = Url.createObjectUrl(ms);
    setSmall(main_vid);
    setLarge(aux_vid);
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
    setSmall(aux_vid);
    setLarge(main_vid);
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
      main_vid.width = MAX_WIDTH;
      setLarge(main_vid);
      setSmall(aux_vid);
      //setWidth(main_vid.videoWidth);
      //setHeight(main_vid.videoHeight);
    });
    
  }, (e) {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
  });
  
  
}

void resize() {
  int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
  int containerWidth = w - (MARGIN * 2);
  
  query("#container").style.width = "${containerWidth}px";
  query("#videocontainer").style.width = "${containerWidth}px";
  query("#chatcontainer").style.width = "${containerWidth}px";
}

void setSmall(VideoElement e) {
  
  String aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
  int h = Util.getHeight(MAX_WIDTH ~/ 8, aspectRatio);
  
  e.style.top = "10px";
  e.style.left = "10px";
  e.width = MAX_WIDTH ~/ 8;
  e.height = h;
  //e.style.width = "${(e.width  ~/ 10).toString()}px";
  //e.style.height = "${h.toString()}px";
}

void setLarge(VideoElement e) {
  int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
  String aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
  e.style.top = "0px";
  e.style.left = "0px";
  e.width = w - MARGIN;
  e.height = Util.getHeight(w- MARGIN, aspectRatio);
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