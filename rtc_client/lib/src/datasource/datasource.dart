part of rtc_client;

/**
 * DataSource interface
 */
abstract class DataSource {
  /** Closed state */
  static final int READYSTATE_CLOSE = 0;
  
  /** Open state */
  static final int READYSTATE_OPEN = 1;
  
  /** Getter for current readyState */
  int get readyState;
  
  /**
   * Closes the connection
   */
  void close();
  
  /**
   * Initializes the connection
   */
  void init();
  
  /**
   * Send data over connection
   */
  void send(String p);
  
  /**
   * Subscribe for DataSource events
   */
  void subscribe(DataSourceEventListener l);
}
