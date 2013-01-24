part of rtc_server;

class WheelUser extends User {
  WheelUser.With(UserContainer uc, String id, WebSocketConnection conn) : super.With(uc, id, conn);
} 
