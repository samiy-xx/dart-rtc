part of rtc_client;

abstract class DataSource {
  static final int READYSTATE_CLOSE = 0;
  static final int READYSTATE_OPEN = 1;
  
  int get readyState;
  
  void close();
  void init();
  void send(String p);
  void subscribe(DataSourceEventListener l);
}
