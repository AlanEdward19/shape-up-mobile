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

  String toStringPtBr() {
    return name;
  }

  @override
  String toString() {
    return this.name.split('.').last;
  }

  static WorkoutVisibility getWithString(String value) {
    return WorkoutVisibility.values.firstWhere((e) => e.toString().toLowerCase() == value.toLowerCase(), orElse: () => WorkoutVisibility.private);
  }
}