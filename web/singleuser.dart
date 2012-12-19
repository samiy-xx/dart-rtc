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
  
  String host = "ws://127.0.0.1:8234/ws";
  sh.initialize(host);
  
  
  
  window.on.beforeUnload.add((e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    e.stopPropagation();
    
    
    sh.close();
    sh = null;
  });
  
  sh.registerHandler("connected", (ConnectionSuccessPacket p) {
    print ("packet");
  });
  
}