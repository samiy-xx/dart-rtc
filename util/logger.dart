part of rtc_utils;

class Logger {
  
  static Logger _instance;
  
  factory Logger() {
    if (_instance == null) {
      _instance = new Logger._internal();
    }
    return _instance;
  }
  
  Logger._internal();
  
  void Debug(String message) {
    _log("Debug", message);
  }
  
  void Error(String message) {
    _log("Error", message);
  }
  
  void Info(String message) {
    _log("Info", message);
  }
  
  void Warning(String message) {
    _log("Warning", message);
  }
  
  void _log(String level, String message) {
    var now = new Date.now();
    output("[$now] [$level] $message", level);
  }
  
  void output(String message, String level) {
    print(message);
  }
}