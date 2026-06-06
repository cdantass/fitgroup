import 'package:flutter/material.dart';

import '../models/app_data.dart';
import 'workout_detail_screen.dart';

const Color kDarkNavy = Color(0xFF1C2333);
const Color kWhite = Color(0xFFFFFFFF);
const Color kLightGrey = Color(0xFFF5F5F5);
const Color kBorderGrey = Color(0xFFE0E0E0);
const Color kTextGrey = Color(0xFF9E9E9E);
const Color kTextDark = Color(0xFF1C2333);

class RotinasScreen extends StatefulWidget {
  const RotinasScreen({super.key});

  @override
  State<RotinasScreen> createState() => _RotinasScreenState();
}

class _RotinasScreenState extends State<RotinasScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _abaDescobrir = false; // controla qual aba está ativa

  final List<Workout> _minhasRotinas = [
    AppData.workouts[0],
    AppData.workouts[1],
  ];

  final List<Workout> _rotinasDescobrir = [
    AppData.workouts[2],
    AppData.workouts[1],
    AppData.workouts[0],
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rotinas = _abaDescobrir ? _rotinasDescobrir : _minhasRotinas;

    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildRotinasList(rotinas, _abaDescobrir)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/criar'),
        backgroundColor: kDarkNavy,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: kWhite, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kDarkNavy,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 600,
                  height: 600,
                  child: Image.asset(
                    'img/logo_fitgroup.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => CustomPaint(
                      size: const Size(600, 600),
                      painter: _LogoPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderGrey),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar rotinas',
          hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: kTextGrey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kLightGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Suas rotinas',
              isActive: !_abaDescobrir,
              onTap: () => setState(() => _abaDescobrir = false),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Descobrir',
              isActive: _abaDescobrir,
              onTap: () => setState(() => _abaDescobrir = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotinasList(List<Workout> rotinas, bool isDescobrir) {
    return ListView.separated(
      itemCount: rotinas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rotina = rotinas[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(workout: rotina),
            ),
          ),
          child: _RotinaCard(
            categoria: rotina.subtitle,
            nome: rotina.title,
            autor: 'por FitGroup',
            onEdit: () => _editRotina(index, isDescobrir),
            onDelete: () => _confirmDeleteRotina(index, isDescobrir),
          ),
        );
      },
    );
  }

  Future<void> _editRotina(int index, bool isDescobrir) async {
    final rotina = isDescobrir ? _rotinasDescobrir[index] : _minhasRotinas[index];
    final edited = await _showEditWorkoutDialog(rotina);
    if (edited != null) {
      setState(() {
        if (isDescobrir) {
          _rotinasDescobrir[index] = edited;
        } else {
          _minhasRotinas[index] = edited;
        }
      });
    }
  }

  Future<Workout?> _showEditWorkoutDialog(Workout rotina) async {
    final titleController = TextEditingController(text: rotina.title);
    final subtitleController = TextEditingController(text: rotina.subtitle);
    final formKey = GlobalKey<FormState>();

    final edited = await showDialog<Workout>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar rotina'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Nome da rotina'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: subtitleController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(
                    Workout(
                      title: titleController.text.trim(),
                      subtitle: subtitleController.text.trim(),
                      estimatedMinutes: rotina.estimatedMinutes,
                      exercises: rotina.exercises,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    subtitleController.dispose();
    return edited;
  }

  Future<void> _confirmDeleteRotina(int index, bool isDescobrir) async {
    final rotina = isDescobrir ? _rotinasDescobrir[index] : _minhasRotinas[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir rotina'),
          content: Text('Deseja excluir "${rotina.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        if (isDescobrir) {
          _rotinasDescobrir.removeAt(index);
        } else {
          _minhasRotinas.removeAt(index);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rotina "${rotina.title}" excluída.')),
      );
    }
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = kWhite
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, 8), 6, paint);
    canvas.drawLine(Offset(size.width * 0.3, 14), Offset(size.width * 0.3, 30), paint);
    canvas.drawLine(Offset(size.width * 0.15, 22), Offset(size.width * 0.45, 22), paint);
    canvas.drawLine(Offset(size.width * 0.3, 30), Offset(size.width * 0.18, 44), paint);
    canvas.drawLine(Offset(size.width * 0.3, 30), Offset(size.width * 0.42, 44), paint);

    canvas.drawCircle(Offset(size.width * 0.7, 8), 6, paint);
    canvas.drawLine(Offset(size.width * 0.7, 14), Offset(size.width * 0.7, 30), paint);
    canvas.drawLine(Offset(size.width * 0.55, 22), Offset(size.width * 0.85, 22), paint);
    canvas.drawLine(Offset(size.width * 0.7, 30), Offset(size.width * 0.58, 44), paint);
    canvas.drawLine(Offset(size.width * 0.7, 30), Offset(size.width * 0.82, 44), paint);

    final barPaint = Paint()
      ..color = kWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.38, 22), Offset(size.width * 0.62, 22), barPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width * 0.35, 22), width: 6, height: 10), fill);
    canvas.drawRect(Rect.fromCenter(center: Offset(size.width * 0.65, 22), width: 6, height: 10), fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isActive ? kDarkNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? kWhite : kTextDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RotinaCard extends StatelessWidget {
  final String categoria;
  final String nome;
  final String autor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _RotinaCard({
    required this.categoria,
    required this.nome,
    required this.autor,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderGrey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoria, style: TextStyle(fontSize: 11, color: kTextGrey, fontWeight: FontWeight.w400)),
                const SizedBox(height: 4),
                Text(nome, style: const TextStyle(fontSize: 15, color: kTextDark, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(autor, style: TextStyle(fontSize: 13, color: kTextGrey)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: kTextGrey, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(value: 'delete', child: Text('Excluir')),
            ],
          ),
        ],
      ),
    );
  }
}