part of demo_client;
/**
 * Very messy notifier class
 */
class Notifier {
  /* singleton instance */
  static Notifier _instance;
  
  /* id of the dom element to create */
  String _elementId = "#xzy_notifier";
  
  /* div element */
  DivElement _element;
  
  /* Where the text goes */
  HeadingElement _text;
  
  /* Height of the notify */
  int _height = 60;
  
  /* interval id */
  int _id;
  
  /* loop interval */ 
  int _interval = 300;
  
  /* timeout after last message shown */
  int _timeout = 4000;
  
  /* Is element visible */
  bool _visible = false;
  
  /* List of messages */
  List<Message> _messages;
  
  /** Notify element */
  Element get element => _element;
  
  
  /**
   * Factory constructor
   */
  factory Notifier() {
    if (_instance == null)
      _instance = new Notifier._internal();
    return _instance;
  }
  
  /**
   * Internal constructor
   */
  Notifier._internal() {
    DivElement e;
    try {
      e = query(_elementId);
    } catch(e) { 
    }
    
    if (e == null) {
      e = new DivElement();
      e.id = _elementId;
    }
    _element = e;
    document.body.nodes.add(e);
    setInitialStyle();
    _messages = new List<Message>();
  }
  
  /**
   * Sets the background color
   */
  void setBackground(String bg) {
    _element.style.background = bg;
  }
  
  /**
   * Sets the size of the notification
   */
  void setSize() {
    _element.style.left = "0px";
    _element.style.top = "0px";
    _element.style.width = generateCssWidth(document.documentElement.clientWidth);
    _element.style.height = generateCssWidth(_height);
  }
  
  /**
   * Sets the initial style
   */
  void setInitialStyle() {
    hide();
    _element.style.background = "#00CCFF";
    _element.style.zIndex = "9999";
    _element.style.border = "0px";
    _element.style.borderBottom = "1px solid #000";
    _element.style.position = "absolute";
    _element.style.margin = "0px";
    _element.style.padding = "0px";
    _element.style.textAlign = "center";
    _text = new HeadingElement.h2();
    _element.children.add(_text);
    setSize();
  }
  
  /**
   * Generates a css friendly unit ie. 100px
   */
  String generateCssWidth(int w) {
    StringBuffer buffer = new StringBuffer();
    buffer.add(w.toString());
    buffer.add("px");
    return buffer.toString();
  }
  
  /**
   * get the first message in queue and assign it to the dom element
   */
  bool popMessage() {
    if (_messages.isEmpty)
      return false;
    
    Message m = _messages.removeAt(0);
    _text.text = m.message;
      
    if (m.callback != null)
      m.callback();
      
    return true;
  }
  
  /**
   * Pops up the notification
   * sets a interval
   */
  void popup() {
    _visible = true;
    _element.style.display = "block";
    if (_id != null)
      window.clearInterval(_id);
    
    popMessage();
    int i = 0;
    
    _id = window.setInterval(() {
      if (!popMessage()) {
        i++;
      } else {
        
      }
      
      if (i >= 5) {
        i = 0;
        hide();
      }
    }, _interval);
  }
  
  /**
   * Hides the notification and clears interval
   */
  void hide() {
    if (_id != null) {
      window.clearInterval(_id);
      _id = null;
    }
    _visible = false;
    _element.style.display = "none";
  }
  
  /**
   * Adds a message to the queue and pops up the notification if not visible
   * @param message a string message to display
   * @param optional callback function
   */
  void display(String message, [Function callback]) {
    setSize();
    _messages.addLast(new Message(message, callback));
    if (!_visible)
      popup();
  }
  
}

class Message {
  String message;
  Function callback;
  Message(this.message, this.callback);
}
