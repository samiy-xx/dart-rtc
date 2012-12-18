part of rtc_server;

class RoomUserContainer extends UserContainer {
  /* Store rooms */
  List<Room> _rooms;
  
  /* logger singleton instance */
  Logger logger = new Logger();
  
  int get roomCount => _rooms.length;
  /*
   * Default constructor
   * @param Server
   */
  RoomUserContainer(Server s) : super(s) {
    _rooms = new List<Room>();
  }
  
  void cleanUp() {
    super.cleanUp();
    logger.Debug("Rooms active: ${_rooms.length}");
    for (int i = 0; i < _rooms.length; i++) {
      Room r = _rooms[i];
      if (usersInRoom(r) == 0) {
        _rooms.removeAt(_rooms.indexOf(r));
      }
    }
  }
  
  void removeUser(User u) {
    super.removeUser(u);
    RoomUser ru = u as RoomUser;
    if (ru.room != null)
      ru.room.leave(u);
  }
  
  List<RoomUser> usersInRoom(Room r) {
    return _users.filter((RoomUser u) => u._room == r);
  }
  
  /**
   * Finds room in container by id
   */
  Room findRoom(String id) {
    for(int i = 0; i < _rooms.length; i++) {
      Room r = _rooms[i];
      if (r.id == id)
        return r;
    }
    
    return null;
  }
  
  void removeRoom(Room r) {
    if (_rooms.contains(r)) {
      _rooms.removeAt(_rooms.indexOf(r));
    }
  }
  /**
   * Creates a room with random id
   */
  Room createRoom() {
    String id = Util.generateId();
    return createRoomWithId(id, 5);
  }
  
  Room createRoomWithId(String id, int limit) {
    
    Room r = new Room.With(id, limit);
    r.container = this;
    _rooms.add(r);
    
    return r;
  }
  
}
