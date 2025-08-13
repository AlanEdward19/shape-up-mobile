enum WorkoutVisibility {
  public,
  friendsOnly,
  private;

  String get name => toString().split('.').last;

  @override
  String toString() {
    return name;
  }
}