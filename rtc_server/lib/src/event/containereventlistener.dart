part of rtc_server;

abstract class ContainerEventListener {
  
}

abstract class ContainerContentsEventListener extends ContainerEventListener{
  onCountChanged(BaseContainer container);
}

abstract class ContainerQueueEventListener extends ContainerEventListener {
  onEnterQueue(User u, int count, int position);
  onMoveInQueue(User u, int count, int position);
  onLeaveQueue(User u);
}

