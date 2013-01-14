part of rtc_server;

abstract class ContainerEventListener {
  
}

abstract class ContainerContentsEventListener extends ContainerEventListener{
  onCountChanged(BaseContainer container);
}

