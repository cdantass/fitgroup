import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_data.dart';
import '../theme/app_theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  void _openEditSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditExerciseSheet(
        exercise: widget.workout.exercises[index],
        onSave: (series, reps, weight, duration) {
          setState(() {
            widget.workout.exercises[index].series = series;
            if (widget.workout.exercises[index].durationMinutes != null) {
              widget.workout.exercises[index].durationMinutes = duration;
            } else {
              widget.workout.exercises[index].reps = reps;
              widget.workout.exercises[index].weight = weight;
            }
          });
        },
      ),
    );
  }

  void _toggleComplete(int index) {
    setState(() {
      widget.workout.exercises[index].completed =
          !widget.workout.exercises[index].completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.workout.exercises.where((e) => e.completed).length;
    final total = widget.workout.exercises.length;
    final allDone = completed == total && total > 0;

    return Scaffold(
      backgroundColor: AppTheme.cardDark,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, completed, total),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.cardDark,
              ),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 40),
                itemCount: widget.workout.exercises.length + (allDone ? 1 : 0),
                separatorBuilder: (_, i) {
                  if (i >= widget.workout.exercises.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Divider(
                    color: Colors.white.withOpacity(0.07),
                    height: 1,
                    indent: 72,
                    endIndent: 20,
                  );
                },
                itemBuilder: (_, i) {
                  if (i == widget.workout.exercises.length) {
                    return _buildCompleteBanner();
                  }
                  return _ExerciseRow(
                    exercise: widget.workout.exercises[i],
                    index: i,
                    onToggle: () => _toggleComplete(i),
                    onEdit: () => _openEditSheet(i),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.chevron_left_rounded,
                      color: Colors.white60, size: 20),
                  Text(
                    'Treinos',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.workout.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$total exercícios · ${widget.workout.estimatedMinutes} min',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximos exercícios',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? AppTheme.teal : AppTheme.purple,
                ),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Treino completo!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.teal,
                  fontSize: 16,
                ),
              ),
              Text(
                'Parabéns, continue assim!',
                style: TextStyle(
                  color: AppTheme.teal.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _ExerciseRow({
    required this.exercise,
    required this.index,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: exercise.completed
                      ? AppTheme.primaryDark
                      : Colors.transparent,
                  border: Border.all(
                    color: exercise.completed
                        ? AppTheme.primaryDark
                        : Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: exercise.completed
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: exercise.completed
                          ? Colors.white.withOpacity(0.4)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      decoration: exercise.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exercise.detail,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: Colors.white.withOpacity(0.2),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}


class _EditExerciseSheet extends StatefulWidget {
  final Exercise exercise;
  final Function(int series, int reps, double weight, int? duration) onSave;

  const _EditExerciseSheet({required this.exercise, required this.onSave});

  @override
  State<_EditExerciseSheet> createState() => _EditExerciseSheetState();
}

class _EditExerciseSheetState extends State<_EditExerciseSheet> {
  late int _series;
  late int _reps;
  late double _weight;
  late int _duration;

  @override
  void initState() {
    super.initState();
    _series = widget.exercise.series;
    _reps = widget.exercise.reps;
    _weight = widget.exercise.weight;
    _duration = widget.exercise.durationMinutes ?? 30;
  }

  bool get isCardio => widget.exercise.durationMinutes != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ajuste séries, repetições e carga',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),

          _StepperRow(
            label: 'Séries',
            value: _series,
            unit: 'x',
            min: 1,
            max: 10,
            onDecrement: () => setState(() => _series = (_series - 1).clamp(1, 10)),
            onIncrement: () => setState(() => _series = (_series + 1).clamp(1, 10)),
          ),
          const SizedBox(height: 16),

          if (isCardio) ...[
            _StepperRow(
              label: 'Duração',
              value: _duration,
              unit: 'min',
              step: 5,
              min: 5,
              max: 120,
              onDecrement: () => setState(() => _duration = (_duration - 5).clamp(5, 120)),
              onIncrement: () => setState(() => _duration = (_duration + 5).clamp(5, 120)),
            ),
          ] else ...[
            _StepperRow(
              label: 'Repetições',
              value: _reps,
              unit: 'reps',
              min: 1,
              max: 50,
              onDecrement: () => setState(() => _reps = (_reps - 1).clamp(1, 50)),
              onIncrement: () => setState(() => _reps = (_reps + 1).clamp(1, 50)),
            ),
            const SizedBox(height: 16),
            _WeightInput(
              weight: _weight,
              onChanged: (v) => setState(() => _weight = v),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(_series, _reps, _weight,
                    isCardio ? _duration : null);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final int step;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.unit,
    this.min = 1,
    this.max = 50,
    this.step = 1,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _CircleBtn(
            icon: Icons.remove_rounded,
            onTap: value > min ? onDecrement : null,
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 52,
            child: Text(
              '$value $unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          _CircleBtn(
            icon: Icons.add_rounded,
            onTap: value < max ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}


class _WeightInput extends StatefulWidget {
  final double weight;
  final ValueChanged<double> onChanged;

  const _WeightInput({required this.weight, required this.onChanged});

  @override
  State<_WeightInput> createState() => _WeightInputState();
}

class _WeightInputState extends State<_WeightInput> {
  late TextEditingController _controller;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    final initial = widget.weight == 0
        ? ''
        : (widget.weight % 1 == 0
            ? widget.weight.toInt().toString()
            : widget.weight.toString());
    _controller = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.'));
    widget.onChanged(parsed ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focus.hasFocus
              ? AppTheme.purple.withOpacity(0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Carga',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: _onChanged,
              onTap: () => setState(() {}),
              onEditingComplete: () {
                _focus.unfocus();
                setState(() {});
              },
            ),
          ),
          Text(
            'kg',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}


class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.purple.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
        child: Icon(
          icon,
          color: active ? AppTheme.purple : Colors.white.withOpacity(0.2),
          size: 20,
        ),
      ),
    );
  }
}