enum WorkoutStatus{
  inProgress,
  finished,
  cancelled;

  String toStringPtBr() {
    switch (this) {
      case WorkoutStatus.inProgress:
        return 'Em progresso';
      case WorkoutStatus.finished:
        return 'Finalizado';
      case WorkoutStatus.cancelled:
        return 'Cancelado';
    }
  }

  @override
  String toString() {
    return this.name.split('.').last;
  }

  static WorkoutStatus getWithString(String value) {
    return WorkoutStatus.values.firstWhere(
      (e) => e.toString().toLowerCase() == value.toLowerCase(),
      orElse: () => WorkoutStatus.inProgress,
    );
  }
}