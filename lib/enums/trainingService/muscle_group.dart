enum MuscleGroup {
  chest,
  upperChest,
  lowerChest,

  triceps,
  biceps,
  forearms,

  deltoidAnterior,
  deltoidLateral,
  deltoidPosterior,
  traps,

  upperBack,
  middleBack,
  lowerBack,
  lats,

  absUpper,
  absLower,
  absObliques,

  quadriceps,
  hamstrings,
  glutes,
  calves,
  hipFlexors,

  fullBody;

  @override
  String toString() {
    switch (this){
      case MuscleGroup.chest:
        return 'Peitoral';
      case MuscleGroup.upperChest:
        return 'Peitoral Superior';
      case MuscleGroup.lowerChest:
        return 'Peitoral Inferior';
      case MuscleGroup.triceps:
        return 'Tríceps';
      case MuscleGroup.biceps:
        return 'Bíceps';
      case MuscleGroup.forearms:
        return 'Antebraços';
      case MuscleGroup.deltoidAnterior:
        return 'Deltoide Anterior';
      case MuscleGroup.deltoidLateral:
        return 'Deltoide Lateral';
      case MuscleGroup.deltoidPosterior:
        return 'Deltoide Posterior';
      case MuscleGroup.traps:
        return 'Trapézio';
      case MuscleGroup.upperBack:
        return 'Costas Superiores';
      case MuscleGroup.middleBack:
        return 'Costas Médias';
      case MuscleGroup.lowerBack:
        return 'Costas Inferiores';
      case MuscleGroup.lats:
        return 'Dorsal';
      case MuscleGroup.absUpper:
        return 'Abdômen Superior';
      case MuscleGroup.absLower:
        return 'Abdômen Inferior';
      case MuscleGroup.absObliques:
        return 'Oblíquos';
      case MuscleGroup.quadriceps:
        return 'Quadríceps';
      case MuscleGroup.hamstrings:
        return 'Isquiotibiais';
      case MuscleGroup.glutes:
        return 'Glúteos';
      case MuscleGroup.calves:
        return 'Panturrilhas';
      case MuscleGroup.hipFlexors:
        return 'Flexores do Quadril';
      case MuscleGroup.fullBody:
        return 'Corpo Inteiro';
    }
  }
}