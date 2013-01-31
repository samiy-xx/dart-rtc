part of rtc_common;

/**
 * Generic event target class
 */
class GenericEventTarget<T> {
  /* List holding listeners */
  List<T> _listeners;
  
  /** Getter for listeners provided by GenericEventTarget */
  List<T> get listeners => _listeners;
  
  /**
   * Constructor
   */
  GenericEventTarget() {
    _listeners = new List<T>();
  }
  
  /**
   * Returns all listeners provided by GenericEventTarget
   */
  List<T> getListeners() {
    return _listeners;
  }
  
  /**
   * Subscribe
   */
  void subscribe(T listener) {
    if (!_listeners.contains(listener))
      _listeners.add(listener);
  }
  
  /**
   * Unsubscribe
   */
  void unsubscribe(T listener) {
    if (_listeners.contains(listener))
      _listeners.removeAt(_listeners.indexOf(listener));
  }
}