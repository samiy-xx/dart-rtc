part of rtc_server;

/**
 * BaseContainer
 * Base class for containers
 */
class BaseContainer<T> extends GenericEventTarget<ContainerEventListener> {
  /* Reference to Server */
  Server _server;
  
  /* Generic list for whichever container type this */
  List<T> _list;
  
  /** Reference to the Server */
  Server get server => getServer();
  
  /** Gets list length */
  int get count => _list.length;
  
  /**
   * Constructor
   * @param s Server
   */
  BaseContainer(Server s) {
    _server = s;
    _list = new List<T>();
  }
  
  /**
   * Gets the Server
   */
  Server getServer() {
    return _server;
  }
  
  /**
   * Adds a new entry to the list
   * Notifiers listeners that collection count has changed
   */
  void add(T e) {
    _list.add(e);
    listeners.where((l) => l is ContainerContentsEventListener).forEach((ContainerContentsEventListener l) {
      l.onCountChanged(this);
    });
  }
  
  /**
   * Removes entry from the list
   * Notifiers listeners that collection count has changed
   */
  void remove(T e) {
    if (_list.contains(e))
      _list.removeAt(_list.indexOf(e));
    
    listeners.where((l) => l is ContainerContentsEventListener).forEach((ContainerContentsEventListener l) {
      l.onCountChanged(this);
    });
  }
  
  
}
