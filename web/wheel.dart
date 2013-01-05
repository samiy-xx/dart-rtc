import 'dart:html';

import '../util/rtc_utils.dart';
import 'single/single_client.dart';
import '../client/rtc_client.dart';
import '../packet/packet.dart';

const int MARGIN = 10;
const int MAX_WIDTH = 800;

void main() {
  //WebLogger logger = new WebLogger();
  //logger.setElement("#log");
  
  Notifier notify = new Notifier();
  notify.setParent("#videocontainer");
  WheelSignalHandler sh = new WheelSignalHandler();
  PeerManager pm = new PeerManager();
  LocalMediaStream ms;
  
  //sh.channelId = "123";
  
  VideoElement main_vid = query("#main");
  VideoElement aux_vid = query("#aux");
  VideoElement large = main_vid;
  ButtonElement next = query("#next");
  DivElement chatInput = query("#chatTextToEnter");
  DivElement chatTextContainer = query("#chatText");
  
  window.on.resize.add((e) {
    resize(large);
  });
  
  chatInput.on.keyUp.add((KeyboardEvent e) {
    if (e.keyCode == 13 && !e.shiftKey) {
      sh.sendMessage("123", chatInput.text);
      appendNewMessageLine("ME", chatInput.text);
      chatInput.text = "";
      new Logger().Debug("Chat text entered");
    }
  });
  
  next.on.click.add((e) {
    aux_vid.pause();
    
    //pm.closeAll();
    sh.requestRandomUser();
    notify.display("Requesting random user...", () {
      //sh.requestRandomUser();
    });
    new Logger().Debug("Requesting random user");
  });
  /*be.on.click.add((_) {
     
     
  });*/
  
  pm.subscribe((MediaStream ms, String id, bool isMain) {
    new Logger().Debug("Incoming video stream");
    notify.display("Incoming video stream");
    aux_vid.src = Url.createObjectUrl(ms);
    aux_vid.on.loadedMetadata.add((e) {
      setSmall(main_vid);
      setLarge(aux_vid);
      large = aux_vid;
    });
  });
  
  window.on.beforeUnload.add((e) {
    sh.close();
    sh = null;
  });
  
  sh.registerHandler("usermessage", (UserMessage m) {
    new Logger().Debug("UserMessage");
    appendNewMessageLine(m.id, m.message);
  });
  
  sh.registerHandler("connected", (ConnectionSuccessPacket p) {
    new Logger().Debug("Connected to signlaing server");
    notify.display("Connected to signaling server succesfully!");
  });
  
  sh.registerHandler("disconnected", (Disconnected p) {
    new Logger().Debug("User disconnected");
    notify.display("User disconnected...");
    setSmall(aux_vid);
    setLarge(main_vid);
    large = main_vid;
    chatInput.contentEditable = "false";
  });
    
  sh.registerHandler("bye", (ByePacket p) {
    new Logger().Debug("User left");
    notify.display("User disconnected...");
    setSmall(aux_vid);
    setLarge(main_vid);
    large = main_vid;
    chatInput.contentEditable = "false";
  });
  
  sh.registerHandler("id", (IdPacket p) {
    new Logger().Debug("User idpacket");
    if (p.id != null && !p.id.isEmpty) {
      notify.display("User connected...");
      chatInput.contentEditable = "true";
    } else {
      notify.display("No users available.");
    }
  });
  
  sh.registerHandler("join", (JoinPacket p) {
    new Logger().Debug("USer joinpacket");
  });
  
  notify.display("Allow access to web camera!");
  new Logger().Debug("Requesting access to camerA");
  window.navigator.webkitGetUserMedia({'video': true, 'audio': true}, (LocalMediaStream stream) {
    ms = stream;
    sh.initialize();
    sh.getPeerManager().setLocalStream(ms);
    main_vid.src = Url.createObjectUrl(stream);
    
    new Logger().Debug("Connecting to signaling server");
    notify.display("Connecting to signaling server...");
    setLarge(main_vid);
    setSmall(aux_vid);
    main_vid.on.loadedMetadata.add((e) {
      setLarge(main_vid);
      setSmall(aux_vid);
    });
    
  }, (e) {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
  });
  
  
}

void resize([VideoElement l]) {
  int w = document.documentElement.clientWidth > MAX_WIDTH ? MAX_WIDTH : document.documentElement.clientWidth;
  int containerWidth = w - (MARGIN * 2);
  
  query("#container").style.width = "${containerWidth}px";
  query("#videocontainer").style.width = "${containerWidth}px";
  query("#chatcontainer").style.width = "${containerWidth}px";
  
  if (?l)
    setLarge(l);
}

void setSmall(VideoElement e) {
  
  String aspectRatio = Util.aspectRatio(e.videoWidth, e.videoHeight);
  int h = Util.getHeight(MAX_WIDTH ~/ 8, aspectRatio);
  
  e.style.top = "10px";
  e.style.left = "10px";
  e.width = MAX_WIDTH ~/ 8;
  e.height = h;
  e.style.zIndex = "9998";
}

void setLarge(VideoElement e) {
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