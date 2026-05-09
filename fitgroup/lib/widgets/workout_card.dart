import 'package:flutter/material.dart';
import '../models/app_data.dart';
import '../theme/app_theme.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final Function(int) onExerciseToggle;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    required this.onExerciseToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completed = workout.exercises.where((e) => e.completed).length;
    final total = workout.exercises.length;
    final progress = total > 0 ? completed / total : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryDark.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        workout.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$completed/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.more_vert_rounded,
                          color: Colors.white.withOpacity(0.5), size: 20),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppTheme.teal : AppTheme.purple,
                  ),
                  minHeight: 3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              workout.exercises.length > 2 ? 2 : workout.exercises.length,
              (i) => _ExerciseRow(
                exercise: workout.exercises[i],
                onToggle: () => onExerciseToggle(i),
              ),
            ),
            if (workout.exercises.length > 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  '+${workout.exercises.length - 2} exercícios',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onToggle;

  const _ExerciseRow({required this.exercise, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: exercise.completed ? AppTheme.purple : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: exercise.completed
                      ? AppTheme.purple
                      : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: exercise.completed
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    color: exercise.completed
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: exercise.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.white.withOpacity(0.5),
                  ),
                ),
                Text(
                  exercise.detail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}