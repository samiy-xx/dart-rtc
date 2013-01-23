part of rtc_server;

/**
 * UserEventListener interface
 */
abstract class UserEventListener {
  
}

/**
 * UserConnectionEventListener
 * Users connection related events
 */
abstract class UserConnectionEventListener extends UserEventListener {
  /**
   * User socket connection was closed
   */
  void onClose(User user, int code, String reason);
}

