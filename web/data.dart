import 'dart:html';

import '../rtc_util/lib/rtc_util.dart';
import 'single/demo_client.dart';
import '../rtc_client/lib/rtc_client.dart';
import '../rtc_common/lib/rtc_common.dart';

void main() {
  WebDataChannelHandler wsh = new WebDataChannelHandler();
  wsh.initialize();
  
  
}

class WebDataChannelHandler implements PeerMediaEventListener {
  Notifier _notify;
  DataSignalHandler _sh;
  PeerManager _pm;
  
  
  WebDataChannelHandler() {
   
    _notify = new Notifier();
    _sh = new DataSignalHandler(new WebSocketDataSource("ws://127.0.0.1:8234/ws"));
    _sh.dataChannelsEnabled = true;
    _sh.channelId = "abc";
    _pm = new PeerManager();
    
    _sh.registerHandler("usermessage", handleUserMessage);
    _sh.registerHandler("connected", handleConnected);
    _sh.registerHandler("disconnected", handleDisconnected);
    _sh.registerHandler("bye", handleBye);
    _sh.registerHandler("id", handleId);
    _sh.registerHandler("join", handleJoin);
    
    _pm.subscribe(this);
  }
  void initialize() {
    _sh.initialize();
    
  }
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool isMain) {
    new Logger().Debug("Incoming video stream");
    _notify.display("Incoming video stream");
    
  }
  
  void handleUserMessage(UserMessage um) {
    new Logger().Debug("UserMessage");
  }
  
  void handleDisconnected(Disconnected d) {
    new Logger().Debug("User disconnected");
    _notify.display("User disconnected...");
    
  }
  
  void handleConnected(ConnectionSuccessPacket csp) {
    new Logger().Debug("Connected to signaling server");
    _notify.display("Connected to signaling server succesfully!");
  }
  
  void handleBye(ByePacket bp) {
    new Logger().Debug("User left");
    _notify.display("User disconnected...");
    
  }
  
  void handleId(IdPacket ip) {
    new Logger().Debug("User idpacket");
    if (ip.id != null && !ip.id.isEmpty) {
      _notify.display("User connected...");
      
    } else {
      _notify.display("No users available.");
    }
  }
  
  void handleJoin(JoinPacket jp) {
    new Logger().Debug("USer joinpacket");
  }
}