part of rtc_client;

class PeerStateChangedEvent extends RtcEvent {
  PeerWrapper peerwrapper;
  String state;
  
  PeerStateChangedEvent(PeerWrapper p, String s) {
    peerwrapper = p;
    state = s;
  }
}

class IceGatheringStateChangedEvent extends RtcEvent {
  PeerWrapper peerwrapper;
  String state;
  
  IceGatheringStateChangedEvent(PeerWrapper p, String s) {
    peerwrapper = p;
    state = s;
  }
}