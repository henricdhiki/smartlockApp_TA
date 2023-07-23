class DoorUpdate {
  String message;
  DoorUpdate(this.message);
}

class DoorAlert {
  String name;
  String message;
  DoorAlert(this.name, this.message);
}

class DoorRemoved {
  String messsage;
  DoorRemoved(this.messsage);
}

class DoorAdded {
  String messsage;
  DoorAdded(this.messsage);
}
