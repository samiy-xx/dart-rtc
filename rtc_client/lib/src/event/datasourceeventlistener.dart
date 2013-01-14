part of rtc_client;

/**
 * Base DataSourceEvent interface
 */
abstract class DataSourceEventListener {
 
}

/**
 * DataSource connection events interface
 */
abstract class DataSourceConnectionEventListener extends DataSourceEventListener {
  /**
   * Datasource received message
   */
  void onMessage(String m);
  
  /**
   * Datasource is closing
   */
  void onClose(String m);
  
  /**
   * Datasource connection opens
   */
  void onOpen(String m);
  
  /**
   * Datasource error
   */
  void onError(String e);
}


