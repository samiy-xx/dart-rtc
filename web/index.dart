library webclient;

import 'dart:html';
import '../client/rtc_client.dart';
import '../util/logger.dart';

part "websignalhandler.dart";
part "webvideomanager.dart";
part "webvideocontainer.dart";

void main() {
  
  // This is where the your local video stream goes initially
  DivElement main = query("#main");
  
  // And here goes streams that are not assigned to go to the main slot
  DivElement aux = query("#aux");
  
  String path;
  
  List pathList = window.location.pathname.split('/');
  
  path = (pathList.length > 0) ? pathList.last : "test";
  
  window.alert("${window.location.pathname} ${path}");
  
  VideoManager vm = new WebVideoManager();
  SignalHandler sh = new WebSignalHandler();
  //PeerManager peerManager = new PeerManager();
  
  VideoContainer vc = vm.addVideoContainer("main_user", "main");
  
  window.navigator.webkitGetUserMedia({'video': true, 'audio': true}, (LocalMediaStream stream) {
    vc.setStream(stream);
    SignalHandler s = new SignalHandler(stream, roomId, userId);
    window.on.beforeUnload.add((_) {
      s.close();
    });
    
  }, (e) {
    Logger log = new Logger();
    log.Error("failed to get userMedia");
  });
}

