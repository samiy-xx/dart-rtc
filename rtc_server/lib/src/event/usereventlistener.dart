part of rtc_server;

abstract class UserEventListener {
  
}

abstract class UserConnectionEventListener extends UserEventListener {
  void onClose(User user, int code, String reason);
}

