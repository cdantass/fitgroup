import 'package:flutter/material.dart';
import 'rotinas_screen.dart';

class DescobrirScreen extends StatefulWidget {
  const DescobrirScreen({super.key});

  @override
  State<DescobrirScreen> createState() => _DescobrirScreenState();
}

class _DescobrirScreenState extends State<DescobrirScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _rotinas = [
    {'categoria': 'Musculação', 'nome': 'Full Body Avancado', 'autor': 'por João'},
    {'categoria': 'Musculação', 'nome': 'Cardio', 'autor': 'por João'},
    {'categoria': 'Musculação', 'nome': 'Cardio', 'autor': 'por João'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildTabs(context),
                  const SizedBox(height: 16),
                  Expanded(child: _buildRotinasList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: kDarkNavy,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 56, bottom: 24),
      child: Column(
        children: [
          _FitgroupLogo(),
        ],
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

  Widget _buildTabs(BuildContext context) {
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
              isActive: false,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/rotinas');
              },
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Descobrir',
              isActive: true,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotinasList() {
    return ListView.separated(
      itemCount: _rotinas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rotina = _rotinas[index];
        return _RotinaCard(
          categoria: rotina['categoria']!,
          nome: rotina['nome']!,
          autor: rotina['autor']!,
          onEdit: () => _editRotina(index),
          onDelete: () => _confirmDeleteRotina(index),
        );
      },
    );
  }

  Future<void> _editRotina(int index) async {
    final rotina = _rotinas[index];
    final edited = await _showEditRotinaDialog(rotina);
    if (edited != null) {
      setState(() {
        _rotinas[index] = edited;
      });
    }
  }

  Future<Map<String, String>?> _showEditRotinaDialog(Map<String, String> rotina) async {
    final categoriaController = TextEditingController(text: rotina['categoria']);
    final nomeController = TextEditingController(text: rotina['nome']);
    final autorController = TextEditingController(text: rotina['autor']);
    final formKey = GlobalKey<FormState>();

    final edited = await showDialog<Map<String, String>>(
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
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome da rotina'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: autorController,
                  decoration: const InputDecoration(labelText: 'Autor'),
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
                  Navigator.of(context).pop({
                    'categoria': categoriaController.text.trim(),
                    'nome': nomeController.text.trim(),
                    'autor': autorController.text.trim(),
                  });
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    categoriaController.dispose();
    nomeController.dispose();
    autorController.dispose();
    return edited;
  }

  Future<void> _confirmDeleteRotina(int index) async {
    final rotina = _rotinas[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir rotina'),
          content: Text('Deseja excluir "${rotina['nome']}"?'),
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
        _rotinas.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rotina "${rotina['nome']}" excluída.')),
      );
    }
  }
}

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/criar');
      },
      backgroundColor: kDarkNavy,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: kWhite, size: 28),
    );
  }



class _FitgroupLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 45,
          child: CustomPaint(painter: _LogoPainter()),
        ),
        const SizedBox(height: 6),
        const Text(
          'fitgroup',
          style: TextStyle(
            color: kWhite,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'TREINO & BEM-ESTAR',
          style: TextStyle(
            color: kWhite,
            fontSize: 9,
            letterSpacing: 3,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
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
    canvas.drawLine(
        Offset(size.width * 0.3, 14), Offset(size.width * 0.3, 30), paint);
    canvas.drawLine(
        Offset(size.width * 0.15, 22), Offset(size.width * 0.45, 22), paint);
    canvas.drawLine(
        Offset(size.width * 0.3, 30), Offset(size.width * 0.18, 44), paint);
    canvas.drawLine(
        Offset(size.width * 0.3, 30), Offset(size.width * 0.42, 44), paint);

    canvas.drawCircle(Offset(size.width * 0.7, 8), 6, paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 14), Offset(size.width * 0.7, 30), paint);
    canvas.drawLine(
        Offset(size.width * 0.55, 22), Offset(size.width * 0.85, 22), paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 30), Offset(size.width * 0.58, 44), paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 30), Offset(size.width * 0.82, 44), paint);

    final barPaint = Paint()
      ..color = kWhite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.38, 22),
        Offset(size.width * 0.62, 22), barPaint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width * 0.35, 22), width: 6, height: 10),
        fill);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width * 0.65, 22), width: 6, height: 10),
        fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

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
                Text(
                  categoria,
                  style: TextStyle(
                    fontSize: 11,
                    color: kTextGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 15,
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  autor,
                  style: TextStyle(
                    fontSize: 13,
                    color: kTextGrey,
                  ),
                ),
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