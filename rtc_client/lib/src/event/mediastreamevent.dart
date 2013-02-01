part of rtc_client;

class MediaStreamAvailableEvent extends RtcEvent {
  MediaStream ms;
  PeerWrapper pw;
  
  MediaStreamAvailableEvent(MediaStream m, PeerWrapper p) {
    ms = m;
    pw = p;
  }
}

class MediaStreamRemovedEvent extends RtcEvent {
  PeerWrapper pw;
  
  MediaStreamRemovedEvent(PeerWrapper p) {
    pw = p;
  }
}