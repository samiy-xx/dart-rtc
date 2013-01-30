part of demo_client;

class Resizer {
  Element _e;
  
  int _requestedWidth;
  int _requestedHeight;
  int _requestedX;
  int _requestedY;
  
  int _width;
  int _height;
  int _x;
  int _y;
  int _loopId = null;
  int _loopInterval = 5;
  
  Resizer(Element e, int w, int h, int x, int y) {
    _e = e;
    _e.style.position = "absolute";
    _loopId = 1;
    setPosition(x, y);
    setSize(w, h);
    _requestedX = x;
    _requestedY = y;
    _requestedWidth = w;
    _requestedHeight = h;
    _loopId = null;
  }
  
  void requestNewSize(int w, int h) {
    _requestedWidth = w;
    _requestedHeight = h;
    
    if (_loopId == null)
      startLoop();
  }
  
  void requestNewPosition(int x, int y) {
    _requestedX = x;
    _requestedY = y;
    
    if (_loopId == null)
      startLoop();
  }
  bool setSize(int w, int h) {
    if (w == _width && h == _height)
      return true;
    
    _width = w;
    _height = h;
    
    resize(w, h);
    return false;
  }
  
  bool setPosition(int x, int y) {
    if (x == _x && y == _y)
      return true;
    
    _x = x;
    _y = y;
    
    moveElement(x, y);
    return false;
  }
  
  void moveElement(int x, int y) {
    _e.style.left = cssUnit(x);
    _e.style.top = cssUnit(y);
  }
  
  void resize(int w, int h) {
    _e.style.width = cssUnit(w);
    _e.style.height = cssUnit(h);
  }
  
  void startLoop() {
    _loopId = window.setInterval(() {
      int newWidth = _width;
      int newHeight = _height;
      int newX = _x;
      int newY = _y;
      
      if (_width != _requestedWidth) {
        newWidth += (_requestedWidth > _width) ? 1 : -1;
      }
      
      if (_height != _requestedHeight) {
        newHeight += (_requestedHeight > _height) ? 1 : -1;
      }
      
      if (_x != _requestedX) {
        newX += (_requestedX > _x) ? 1 : -1;
      }
      
      if (_y != _requestedY) {
        newY += (_requestedY > _y) ? 1 : -1;
      }
      
      if (setSize(newWidth, newHeight) && setPosition(newX, newY)) {
        cancelLoop();
      }
    }, _loopInterval);
  }
  
  void cancelLoop() {
    
    window.clearInterval(_loopId);
    _loopId = null;
    
  }
  
  String cssUnit(int w) {
    StringBuffer buffer = new StringBuffer();
    buffer.add(w.toString());
    buffer.add("px");
    return buffer.toString();
  }
}