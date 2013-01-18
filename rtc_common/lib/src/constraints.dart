part of rtc_common;

/**
 * Abstract base class for defining constraints
 * to getUserMedia and mediastream in peer connection
 */
abstract class Constraints {
  /**
   * Returns the object converted into a Map
   */
  Map toMap();
}