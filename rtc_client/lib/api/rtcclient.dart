part of rtc_client;

abstract class RtcClient {
  void initialize();
  RtcClient setRequireAudio(bool b);
  RtcClient setRequireVideo(bool b);
  RtcClient setRequireDataChannel(bool b);
  RtcClient setChannel(String c);
}