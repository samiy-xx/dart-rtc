import 'dart:html';
import 'single/demo_client.dart';
import '../rtc_common/lib/rtc_common.dart';
import '../rtc_client/lib/rtc_client.dart';
void main() {
  FileManager fm = new FileManager();
  WebFileChannelHandler wdch = new WebFileChannelHandler(fm);
  fm.subscribe(wdch);
  wdch.initialize();
}

class WebFileChannelHandler implements PeerMediaEventListener, FileCopyEventListener, PeerDataEventListener {
  Notifier _notify;
  DataSignalHandler _sh;
  PeerManager _pm;
  FileManager _fm;
  
  WebFileChannelHandler(FileManager fm) {
    _fm = fm;
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
    _sh.registerHandler("file", handleFile);
    
    _pm.subscribe(this);
    
    (query("#copy_from_filesystem") as InputElement).onChange.listen((Event e) {
      _fm.addFiles((query("#copy_from_filesystem") as InputElement).files);
    });
  }
  
  void onDataReceived(int buffered) {
    
  }
  
  void onChannelStateChanged(DataPeerWrapper p, String state) {
    _notify.display("DataChannel state is now $state");  
    if (state == "open") {
      p.send(new HeloPacket.With(_sh.id, ""));
      _fm.getAllFiles().forEach((File f) {
        p.send(new FilePacket.With(_sh.id, f.name, f.size.toString()));
        
      });
    }
  }
  
  void onPacket(DataPeerWrapper pw, Packet pp) {
 
    _notify.display("Received ${pp.packetType} packet from data channel");
    if (pp.packetType == "file") {
      FilePacket p = pp;
      (query("#filecontainer_left") as DivElement).append(createNewFileNodeFromString(p.fileName, p.fileSize, "hoho"));
    }
  }
  
  void initialize() {
    _sh.initialize();
  }
  
  void onFileAdded(File f) {
    (query("#filecontainer_left") as DivElement).append(createNewFileNode(f));
  }
  
  void onRemoteMediaStreamAvailable(MediaStream ms, String id, bool isMain) {
    new Logger().Debug("Incoming video stream");
    _notify.display("Incoming video stream");
    
  }
  
  void handleFile(FilePacket p) {
    (query("#filecontainer_left") as DivElement).append(createNewFileNodeFromString(p.fileName, p.fileSize, "hoho"));
  }
  
  void handleUserMessage(UserMessage um) {
    new Logger().Debug("UserMessage");
  }
  
  void handleDisconnected(Disconnected d) {
    DataPeerWrapper dpw = _pm.findWrapper(d.id);
    dpw.unsubscribe(this);
    new Logger().Debug("User disconnected");
    _notify.display("User disconnected...");
    
  }
  
  void handleConnected(ConnectionSuccessPacket csp) {
    new Logger().Debug("Connected to signaling server");
    _notify.display("Connected to signaling server succesfully!");
  }
  
  void handleBye(ByePacket bp) {
    DataPeerWrapper dpw = _pm.findWrapper(bp.id);
    dpw.unsubscribe(this);
    new Logger().Debug("User left");
    _notify.display("User disconnected...");
    
  }
  
  void handleId(IdPacket ip) {
    DataPeerWrapper dpw = _pm.findWrapper(ip.id);
    dpw.subscribe(this);
    new Logger().Debug("User idpacket");
    if (ip.id != null && !ip.id.isEmpty) {
      _notify.display("User connected...");
      
    } else {
      _notify.display("No users available.");
    }
  }
  
  void handleJoin(JoinPacket jp) {
    DataPeerWrapper dpw = _pm.findWrapper(jp.id);
    dpw.subscribe(this);
    
    new Logger().Debug("USer joinpacket");
    
    //_fm.getAllFiles().forEach((File f) {
    //  _sh.send(PacketFactory.get(new FilePacket.With(jp.id, f.name, f.size.toString())));
    //});
  }
  
  Element createNewFileNodeFromString(String name, String size, String type) {
    DivElement node = new DivElement();
    node.classes.add("fileEntry");
    
    SpanElement spanName = new SpanElement();
    spanName.appendText(name);
    spanName.id = "span_1_${name}";
    
    SpanElement spanSize = new SpanElement();
    spanSize.appendText(FileSizeConverter.convert(int.parse(size)));
    spanSize.id = "span_2_${name}";
    
    SpanElement spanType = new SpanElement();
    spanType.appendText(type);
    spanType.id = "span_3_${name}";
    
    node.append(spanName);
    node.append(spanSize);
    node.append(spanType);
    
    node.id = "div_${name}";
    node.style.cursor = "pointer";
    
    
    return node;
  }
  
  Element createNewFileNode(File f) {
    DivElement node = new DivElement();
    node.classes.add("fileEntry");
    
    SpanElement spanName = new SpanElement();
    spanName.appendText(f.name);
    spanName.id = "span_1_${f.name}";
    
    SpanElement spanSize = new SpanElement();
    spanSize.appendText(FileSizeConverter.convert(f.size));
    spanSize.id = "span_2_${f.name}";
    
    SpanElement spanType = new SpanElement();
    spanType.appendText(f.type);
    spanType.id = "span_3_${f.name}";
    
    node.append(spanName);
    node.append(spanSize);
    node.append(spanType);
    
    node.id = "div_${f.name}";
    node.style.cursor = "pointer";
    
    
    return node;
  }
}