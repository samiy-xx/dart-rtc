part of rtc_server_tests;

typedef void onContainerCountChangedCallback(BaseContainer c);

class MockContainerEventListener implements ContainerContentsEventListener {
  int _currentCount;
  int get currentCount => _currentCount;
  onContainerCountChangedCallback _countCallback;
  
  set countCallback(onContainerCountChangedCallback c) => _countCallback = c;
  
  onCountChanged(BaseContainer container) {
    _currentCount = container.count;
    if (_countCallback != null)
      _countCallback(container);
  }
}
