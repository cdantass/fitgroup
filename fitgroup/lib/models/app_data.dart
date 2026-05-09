import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FitGroup {
  final String name;
  final Color color;
  final int members;
  final String emoji;

  const FitGroup({
    required this.name,
    required this.color,
    required this.members,
    required this.emoji,
  });
}

class Exercise {
  final String name;
  int series;
  int reps;
  double weight;
  bool hasWeight;
  int? durationMinutes;
  bool completed;

  Exercise({
    required this.name,
    this.series = 3,
    this.reps = 10,
    this.weight = 0,
    this.hasWeight = true,
    this.durationMinutes,
    this.completed = false,
  });

  String get detail {
    if (durationMinutes != null) {
      return '${series > 1 ? "$series séries · " : ""}${durationMinutes}min';
    }
    final w = weight > 0
        ? ' · ${weight % 1 == 0 ? weight.toInt() : weight}kg'
        : ' · Peso corporal';
    return '$series séries · $reps reps$w';
  }
}

class Workout {
  final String title;
  final String subtitle;
  final int estimatedMinutes;
  final List<Exercise> exercises;

  const Workout({
    required this.title,
    required this.subtitle,
    this.estimatedMinutes = 45,
    required this.exercises,
  });
}

class AppData {
  static List<FitGroup> groups = [
    FitGroup(name: 'Grupo fitness', color: AppTheme.purple, members: 12, emoji: '💪'),
    FitGroup(name: 'Grupo de nutrição', color: AppTheme.amber, members: 8, emoji: '🥗'),
    FitGroup(name: 'Grupo de saúde', color: AppTheme.coral, members: 15, emoji: '❤️'),
    FitGroup(name: 'Yoga & Zen', color: AppTheme.teal, members: 6, emoji: '🧘'),
  ];

  static List<Workout> workouts = [
    Workout(
      title: 'Full body iniciante',
      subtitle: 'Treino completo',
      estimatedMinutes: 45,
      exercises: [
        Exercise(name: 'Agachamento', series: 3, reps: 10, weight: 60, completed: true),
        Exercise(name: 'Cadeira extensora', series: 3, reps: 10, weight: 60),
        Exercise(name: 'Leg press', series: 4, reps: 12, weight: 80),
        Exercise(name: 'Panturrilha', series: 3, reps: 15, weight: 0),
      ],
    ),
    Workout(
      title: 'Cardio',
      subtitle: 'Exercícios',
      estimatedMinutes: 60,
      exercises: [
        Exercise(name: 'Esteira', series: 1, reps: 0, durationMinutes: 30, hasWeight: false, completed: true),
        Exercise(name: 'Bicicleta ergométrica', series: 1, reps: 0, durationMinutes: 20, hasWeight: false),
        Exercise(name: 'Pular corda', series: 1, reps: 0, durationMinutes: 10, hasWeight: false),
      ],
    ),
    Workout(
      title: 'Peito & Tríceps',
      subtitle: 'Treino A',
      estimatedMinutes: 50,
      exercises: [
        Exercise(name: 'Supino reto', series: 4, reps: 10, weight: 60, completed: true),
        Exercise(name: 'Crucifixo', series: 3, reps: 12, weight: 20, completed: true),
        Exercise(name: 'Tríceps Pulley', series: 4, reps: 15, weight: 35),
        Exercise(name: 'Paralelas', series: 3, reps: 12, weight: 0),
        Exercise(name: 'Tríceps testa', series: 3, reps: 12, weight: 20),
      ],
    ),
  ];
}