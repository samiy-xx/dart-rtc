part of rtc_common;

/**
 * PacketHandler
 * Signaling server and client should extend this
 */
class PacketHandler {
  /* Store all method handlers in list */
  Map<PacketType, List<Function>> _methodHandlers;
  
  /**
   * Constructor
   * initialize array
   */
  PacketHandler() {
    _methodHandlers = new Map<PacketType, List<Function>>();
  }
  
  /**
   * Add a new handler for given type
   */
  void registerHandler(PacketType type, Function handler) {
    if (!_methodHandlers.containsKey(type))
      _methodHandlers[type] = new List<Function>();
    _methodHandlers[type].add(handler);
  }
  
  /**
   * Clears all handlers associated to "type"
   */
  void clearHandlers(PacketType type) {
    if (_methodHandlers.containsKey(type))
      _methodHandlers.remove(type);
  }
  
  /**
   * Returns a list of handler functions for given packet type
   */
  List<Function> getHandlers(PacketType type) {
    if (_methodHandlers.containsKey(type))
      return _methodHandlers[type];
    
    return null;
  }
  
  /**
   * Executes packet handlers for given packet if any
   */
  bool executeHandler(Packet p) {
    List<Function> handlers = getHandlers(p.packetType);
    if (handlers == null || handlers.length == 0)
      return false;
      
    for (Function f in handlers)
      f(p);
          
    return true;
  }
 
  /**
   * Executes packet handlers for given object and packet if any
   */
  bool executeHandlerFor(Object c, Packet p) {
      List<Function> handlers = getHandlers(p.packetType);
      if (handlers == null || handlers.length == 0)
        return false;
      
      for (Function f in handlers)
        f(p, c);
          
      return true;
    
  }
}
