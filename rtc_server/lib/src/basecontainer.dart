part of rtc_server;

/**
 * BaseContainer
 * Base class for containers
 */
class BaseContainer {
  /* Reference to Server */
  Server _server;
  
  /** Reference to the Server */
  Server get server => getServer();
  
  /**
   * Constructor
   * @param s Server
   */
  BaseContainer(Server s) {
    _server = s;
  }
  
  /**
   * Gets the Server
   */
  Server getServer() {
    return _server;
  }
}
