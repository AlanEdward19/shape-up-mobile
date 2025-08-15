enum WorkoutStatus{
  inProgress,
  finished,
  cancelled;

  @override
  String toString() {
    switch (this) {
      case WorkoutStatus.inProgress:
        return 'Em progresso';
      case WorkoutStatus.finished:
        return 'Finalizado';
      case WorkoutStatus.cancelled:
        return 'Cancelado';
    }
  }

  static WorkoutStatus getWithString(String value) {
    return WorkoutStatus.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => WorkoutStatus.inProgress,
    );
  }
}