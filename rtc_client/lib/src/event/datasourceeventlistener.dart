part of rtc_client;

abstract class DataSourceEventListener {
 
}

abstract class DataSourceConnectionEventListener extends DataSourceEventListener {
  void onMessage(String m);
  void onClose(String m);
  void onOpen(String m);
  void onError(String e);
}


