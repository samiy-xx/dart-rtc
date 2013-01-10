part of rtc_common;

class PacketHandler {
  /* Store all method handlers in list */
  Map<String, List<Function>> _methodHandlers;
  
  PacketHandler() {
    _methodHandlers = new Map<String, List<Function>>();
  }
  
  void registerHandler(String type, Function handler) {
    if (!_methodHandlers.containsKey(type))
      _methodHandlers[type] = new List<Function>();
    _methodHandlers[type].add(handler);
  }
  
  /**
   * Clears all handlers associated to "type"
   * @param type the message type
   */
  void clearHandlers(String type) {
    if (_methodHandlers.containsKey(type))
      _methodHandlers.remove(type);
  }
  
  /**
   * Returns a list of handler functions for given packet type
   */
  List<Function> getHandlers(String type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return null;
  }
  
  /**
   * Executes packet handlers for given packet if any
   */
  bool executeHandlerFor(Object c, Packet p) {
    try {
    List<Function> handlers = getHandlers(p.packetType);
    
    if (handlers == null || handlers.length == 0)
      return false;
    
    for (Function f in handlers)
      f(p, c);
        
    return true;
    } catch(e) {
      print("execute: $e");
    }
  }
}
