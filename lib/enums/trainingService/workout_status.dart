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
}