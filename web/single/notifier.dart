part of single_client;

class Notifier {
  static Notifier _instance;
  String _elementId = "#xzy_notifier";
  DivElement _element;
  HeadingElement _text;
  int _width = 800;
  int _height = 60;
  int _id;
  int _interval = 2000;
  int _timeout = 5000;
  bool _visible = false;
  Element get element => _element;
  List<Message> _messages;
  
  factory Notifier() {
    if (_instance == null)
      _instance = new Notifier._internal();
    return _instance;
  }
  
  Notifier._internal() {
    DivElement e;
    try {
      e = query(_elementId);
    } catch(e) { 
    }
    
    if (e == null) {
      e = new DivElement();
      e.id = _elementId;
      document.body.children.add(e);
    }
    _element = e;
    _messages = new List<Message>();
    setInitialStyle();
  }
  
  void setBackground(String bg) {
    _element.style.background = bg;
  }
  
  void setInitialStyle() {
    hide();
    _element.style.background = "#eee";
    _element.style.zIndex = "9999";
    _element.style.width = "${_width.toString()}px";
    _element.style.height = "${_height.toString()}px";
    _element.style.border = "1px solid #000";
    _element.style.position = "absolute";
    _element.style.top = "${((window.innerHeight ~/ 2) - (_height ~/ 2)).toString()}px";
    _element.style.left = "${((window.innerWidth ~/ 2) - (_width ~/ 2)).toString()}px";
    _element.style.boxShadow = "0 0 5px 5px #888";
    _element.style.padding = "10px";
    _element.style.textAlign = "center";
    _text = new HeadingElement.h2();
    _element.children.add(_text);
    
    document.on.click.add((_) => hide());
  }
  
  void popup() {
    _visible = true;
    _element.style.display = "block";
    Message m = _messages.removeAt(0);
    _text.text = m.message;
    if (m.callback != null)
      m.callback();
    int i = 0;
    _id = window.setInterval(() {
      i++;
      if (_messages.length > 0) {
        m = _messages.removeAt(0);
        _text.text = m.message;
        if (m.callback != null)
          m.callback();
      }
      
      if (i >= 5) {
        i = 0;
        hide();
      }
    }, _interval);
    
    /*if (_id != null) {
      window.clearTimeout(_id);
    }
    
    _id = window.setTimeout(() {
      hide();
    }, _timeout);
    */
    
  }
  
  void hide() {
    if (_id != null) {
      window.clearInterval(_id);
      _id = null;
    }
    _visible = false;
    _element.style.display = "none";
  }
  
  void display(String message, [Function callback]) {
    //_text.text = message;
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
