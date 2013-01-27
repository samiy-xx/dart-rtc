part of rtc_common_tests;

typedef void onMockTrueCallback(bool isTrue);

class MockMockEventListener implements MockRunningEventListener {
  bool _isTrue = false;
  bool get isTrue => _isTrue;
  onMockTrueCallback _callback;
  
  set callback(onMockTrueCallback c) => _callback = c;
  
  void onMock(bool isTrue) {
    _isTrue = isTrue;
    if (_callback != null)
      _callback(isTrue);
  }
}