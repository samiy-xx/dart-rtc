/**
 * loglevel.dart
 * Copyright (c) 2013 Sami Ylönen sami.ylonen@gmail.com
 */

part of rtc_utils;

/**
 * Enum like class to define logging levels
 */
class LogLevel {
  /** Info Log Level */
  static final LogLevel INFO = const LogLevel(1, "Info");
  
  /** Warn Log level */
  static final LogLevel WARN = const LogLevel(2, "Warn");
  
  /** Error Log level */
  static final LogLevel ERROR = const LogLevel(3, "Error");
  
  /** Debug Log Level */
  static final LogLevel DEBUG = const LogLevel(4, "Debug");
  
  /* Private member level */
  final int _level;
  
  /* Private member type */
  final String _type;
  
  /**
   * Constant constructor
   */
  const LogLevel(int l, String t) : _level = l, _type = t;
  
  /*
   * Less than operator
   */
  operator < (LogLevel o) {
    return _level < o._level;
  }
  
  /* 
   * Less than or equal operator
   */
  operator <= (LogLevel o) {
    return _level <= o._level;
  }
}