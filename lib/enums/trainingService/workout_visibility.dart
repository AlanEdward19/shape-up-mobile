enum WorkoutVisibility {
  public,
  friendsOnly,
  private;

  String get name {
    switch (this) {
      case WorkoutVisibility.public:
        return 'Público';
      case WorkoutVisibility.friendsOnly:
        return 'Somente Amigos';
      case WorkoutVisibility.private:
        return 'Privado';
    }
  }

  @override
  String toString() {
    return name;
  }
}