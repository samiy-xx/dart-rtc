part of rtc_server;

/**
 * Abstract class Server
 */
abstract class Server {
  /**
   * Send Packet to client
   */
  void sendPacket(WebSocketConnection, Packet p);
  
  /**
   * Start listening on socket
   */
  void listen([String ip, int port, String path]);
}

