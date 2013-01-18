part of rtc_common;

class PeerConstraints implements Constraints{
  bool _dataChannelEnabled;
  
  /** Sets the bitrate of the stream */
  set dataChannelEnabled(bool value) => setDataChannelEnabled(value);
  
  PeerConstraints() {
    _dataChannelEnabled = false;
  }
  
  void setDataChannelEnabled(bool value) {
    _dataChannelEnabled = value;
  }
  
  /*
   * Implements Constraints toMap
   */
  Map toMap() {
    return {
      
      'optional' : [{'RtpDataChannels': _dataChannelEnabled}]
    };
  }
}
