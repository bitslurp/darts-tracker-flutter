class Player {
  String _playerName;
  int age;

  Player(this._playerName, this.age);

  String get name {
    return _playerName;
  }

  bool equals(Player other) {
    return name == other.name;
  }
}
