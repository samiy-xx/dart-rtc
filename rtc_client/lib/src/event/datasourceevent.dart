part of rtc_client;

class DataSourceMessageEvent extends RtcEvent {
  String message;
  
  DataSourceMessageEvent(String s) {
    message = s;
  }
}

class DataSourceCloseEvent extends RtcEvent {
  String message;
  
  DataSourceCloseEvent(String s) {
    message = s;
  }
}

class DataSourceOpenEvent extends RtcEvent {
  String message;
  
  DataSourceOpenEvent(String s) {
    message = s;
  }
}

class DataSourceErrorEvent extends RtcEvent {
  String message;
  
  DataSourceErrorEvent(String s) {
    message = s;
  }
}


