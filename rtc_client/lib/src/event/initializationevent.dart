part of rtc_client;

class InitializedEvent extends RtcEvent {
  String message;
  bool initialized;
  
  InitializedEvent(bool i, String m) {
    initialized = i;
    message = m;
  }
}



