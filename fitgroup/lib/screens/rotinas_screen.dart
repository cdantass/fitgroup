import 'package:flutter/material.dart';

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

  final List<Map<String, String>> _rotinas = [
    {'categoria': 'Musculação', 'nome': 'Full Body Iniciante', 'autor': 'por João'},
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
                  _buildTabs(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildRotinasList()),
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
          height: 100,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    'img/logo_fitgroup.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => CustomPaint(
                      size: const Size(200, 200),
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
            child: _TabButton(label: 'Suas rotinas', isActive: true, onTap: () {}),
          ),
          Expanded(
            child: _TabButton(label: 'Descobrir', isActive: false, onTap: () {}),
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
        );
      },
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

  const _RotinaCard({required this.categoria, required this.nome, required this.autor});

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
          Icon(Icons.more_vert, color: kTextGrey, size: 20),
        ],
      ),
    );
  }
}