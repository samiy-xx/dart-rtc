part of rtc_server;

/**
 * Interface for container events
 */
abstract class ContainerEventListener {
  
}

/**
 * Interface for container contents (user/channel) notifications
 */
abstract class ContainerContentsEventListener extends ContainerEventListener{
  /**
   * Container content count changed
   */
  onCountChanged(BaseContainer container);
}

