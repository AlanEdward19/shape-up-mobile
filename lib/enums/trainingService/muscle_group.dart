enum MuscleGroup {
  chest,
  middleChest,
  upperChest,
  lowerChest,

  arms,
  triceps,
  biceps,
  forearms,

  shoulders,
  deltoidAnterior,
  deltoidLateral,
  deltoidPosterior,

  back,
  traps,
  upperBack,
  middleBack,
  lowerBack,
  lats,

  abs,
  absUpper,
  absLower,
  absObliques,

  legs,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  hipFlexors,

  fullBody;

  @override
  String toString() {
    return this.name.split('.').last;
  }

  String toStringPtBr() {
    switch (this){
      case MuscleGroup.chest:
        return 'Peitoral';
      case MuscleGroup.middleChest:
        return 'Peitoral Médio';
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
      case MuscleGroup.arms:
        return 'Braços';
      case MuscleGroup.shoulders:
        return 'Ombros';
      case MuscleGroup.back:
        return 'Costas';
      case MuscleGroup.abs:
        return 'Abdômen';
      case MuscleGroup.legs:
        return 'Pernas';
    }
  }
}

List<MuscleGroup> getMainMuscleGroups() {
  return [
    MuscleGroup.chest,
    MuscleGroup.arms,
    MuscleGroup.shoulders,
    MuscleGroup.back,
    MuscleGroup.abs,
    MuscleGroup.legs,
    MuscleGroup.fullBody
  ];
}

List<MuscleGroup> getRelatedMuscleGroups(MuscleGroup group) {
  switch (group) {
    case MuscleGroup.chest:
      return [
        MuscleGroup.middleChest,
        MuscleGroup.upperChest,
        MuscleGroup.lowerChest,
      ];
    case MuscleGroup.back:
      return [
        MuscleGroup.upperBack,
        MuscleGroup.middleBack,
        MuscleGroup.lowerBack,
        MuscleGroup.lats,
        MuscleGroup.traps,
      ];
    case MuscleGroup.abs:
      return [
        MuscleGroup.absUpper,
        MuscleGroup.absLower,
        MuscleGroup.absObliques,
      ];
    case MuscleGroup.legs:
      return [
        MuscleGroup.quadriceps,
        MuscleGroup.hamstrings,
        MuscleGroup.glutes,
        MuscleGroup.calves,
        MuscleGroup.hipFlexors,
      ];
    case MuscleGroup.shoulders:
      return [
        MuscleGroup.deltoidAnterior,
        MuscleGroup.deltoidLateral,
        MuscleGroup.deltoidPosterior,
      ];
    case MuscleGroup.arms:
      return [
        MuscleGroup.biceps,
        MuscleGroup.triceps,
        MuscleGroup.forearms,
      ];
    default:
      return [];
  }
}

List<MuscleGroup> getSecondaryMuscleGroups() {
  return [
    MuscleGroup.middleChest,
    MuscleGroup.upperChest,
    MuscleGroup.lowerChest,
    MuscleGroup.triceps,
    MuscleGroup.biceps,
    MuscleGroup.forearms,
    MuscleGroup.deltoidAnterior,
    MuscleGroup.deltoidLateral,
    MuscleGroup.deltoidPosterior,
    MuscleGroup.traps,
    MuscleGroup.upperBack,
    MuscleGroup.middleBack,
    MuscleGroup.lowerBack,
    MuscleGroup.lats,
    MuscleGroup.absUpper,
    MuscleGroup.absLower,
    MuscleGroup.absObliques,
    MuscleGroup.quadriceps,
    MuscleGroup.hamstrings,
    MuscleGroup.glutes,
    MuscleGroup.calves,
    MuscleGroup.hipFlexors
  ];
}

MuscleGroup muscleGroupByString(String muscleGroup) {
  return MuscleGroup.values.firstWhere((e) => e.toString().toLowerCase() == muscleGroup.toLowerCase());
}