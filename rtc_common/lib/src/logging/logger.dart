/**
 * logger.dart
 * Copyright (c) 2013 Sami Ylönen sami.ylonen@gmail.com
 */

part of rtc_common;

/**
 * Custom Logger class
 */
class Logger {
  /* instance */
  static Logger instance;
  
  /* Current logging level */
  LogLevel _logLevel;
  
  /** Setter for current log level */
  set level(LogLevel value) => setLevel(value);
  
  /**
   * Factory constructor
   */
  factory Logger() {
    if (instance == null) {
      instance = new Logger._internal();
    }
    return instance;
  }
  
  /*
   * Internal costructor
   */
  Logger._internal() {
    _logLevel = LogLevel.DEBUG;
  }
  
  /**
   * Sets the current log level
   * @param l the new LogLevel
   */
  void setLevel(LogLevel l) {
    _logLevel = l;
  }
  
  /**
   * Logs Debug LogLevel messages
   * @param message to ouput
   */
  void Debug(String message) {
    _log(LogLevel.DEBUG, message);
  }
  
  /**
   * Logs Error LogLevel messages
   * @param message to ouput
   */
  void Error(String message) {
    _log(LogLevel.ERROR, message);
  }
  
  /**
   * Logs Info LogLevel messages
   * @param message to ouput
   */
  void Info(String message) {
    _log(LogLevel.INFO, message);
  }
  
  /**
   * Logs Warning LogLevel messages
   * @param message to ouput
   */
  void Warning(String message) {
    _log(LogLevel.WARN, message);
  }
  
  /*
   * Private log method called from methods above
   * @param level LogLevel
   * @param message String message
   */
  void _log(LogLevel level, String message) {
    if (level >= _logLevel) {
      var now = new Date.now();
      output("[$now] [${level._type}] $message");
    }
  }
  
  /**
   * Outputs the generated log message to console, firebug etc..
   * Override this to add logging to DOMtree for example
   */
  void output(String message) {
    print(message);
  }
}

