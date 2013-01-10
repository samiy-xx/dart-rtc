import 'dart:html';

import '../rtc_util/lib/rtc_util.dart';
import 'single/single_client.dart';
import '../rtc_client/lib/rtc_client.dart';
import '../rtc_common/lib/rtc_common.dart';

void main() {
  // READ https://webrtc-demos.appspot.com/html/constraints-and-stats.html
  
  WebVideoManager vm = new WebVideoManager();
  WebSignalHandler sh = new WebSignalHandler();
  //sh.setDataChannelsEnabled(true);
  sh.channelId = "123";
  
  PeerManager pm = new PeerManager();
  
  // This is where the your local video stream goes initially
  DivElement main = query("#main");
  
  // And here goes stream(s) that is(are) not assigned to the main slot
  DivElement aux = query("#aux");
  
  vm.setMainContainer("#main");
  vm.setChildContainer("#aux");
  
  ButtonElement be = query("#chatSubmit");
  InputElement chatInput = query("#chatTextToEnter");
  DivElement chatTextContainer = query("#chatText");
  
  be.on.click.add((_) {
     sh.sendMessage("123", chatInput.value);
     appendNewMessageLine("ME", chatInput.value);
     chatInput.value = ""; 
  });
  String host = "ws://127.0.0.1:8234/ws";
  //sh.initialize(host);
  
  //pm.subscribe((MediaStream ms, String id, bool isMain) {
  //  print ("GOT STREAM FROM PeerMANAGER!!!!!!!!!");
  //});
  
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
  
  WebVideoContainer vc = vm.addVideoContainer("main_user", "main");
  sh.initialize(host);
  (query("#enableLocalVideo") as ButtonElement).on.click.add((_) {
    window.navigator.webkitGetUserMedia({'video': true, 'audio': true}, (LocalMediaStream stream) {
      vc.setStream(stream);
      vm.setLocalStream(stream);
      sh.getPeerManager().setLocalStream(stream);
      
    }, (e) {
      Logger log = new Logger();
      log.Error("failed to get userMedia");
    });
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