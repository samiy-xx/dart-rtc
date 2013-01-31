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
  void onDataSourceMessage(String m);
  
  /**
   * Datasource is closing
   */
  void onCloseDataSource(String m);
  
  /**
   * Datasource connection opens
   */
  void onOpenDataSource(String m);
  
  /**
   * Datasource error
   */
  void onDataSourceError(String e);
}


