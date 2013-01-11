part of demo_client;

class WebLogger extends Logger {
  DivElement _logElement;
  factory WebLogger() {
    if (instance == null)
      instance = new WebLogger._internal();
    return instance;
  }
  WebLogger._internal() : super._internal();
  
  void setElement(String e) {
    _logElement = query(e);
  }
  
  void output(String message) {
    super.output(message);
    
    if (_logElement != null) {
      DivElement div = new DivElement();
      
      div.appendText (message);
      div.classes.add('logElement');
      
      _logElement.nodes.add(div);
    }
  }
}
