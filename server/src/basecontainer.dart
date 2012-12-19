part of rtc_server;

class BaseContainer {
  /* Reference to Server */
  Server _server;
  
  BaseContainer(Server s) {
    _server = s;
  }
  
  Server getServer() {
    return _server;
  }
}
