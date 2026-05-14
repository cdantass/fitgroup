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
      bottomNavigationBar: const FitgroupBottomNav(selectedIndex: 0),
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
              isActive: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Descobrir',
              isActive: false,
              onTap: () {
                Navigator.pushReplacementNamed(context, '/descobrir');
              },
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
        );
      },
    );
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
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _FitgroupLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícone customizado com duas figuras e haltere
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

    // Pessoa esquerda
    canvas.drawCircle(Offset(size.width * 0.3, 8), 6, paint);
    canvas.drawLine(
        Offset(size.width * 0.3, 14), Offset(size.width * 0.3, 30), paint);
    canvas.drawLine(
        Offset(size.width * 0.15, 22), Offset(size.width * 0.45, 22), paint);
    canvas.drawLine(
        Offset(size.width * 0.3, 30), Offset(size.width * 0.18, 44), paint);
    canvas.drawLine(
        Offset(size.width * 0.3, 30), Offset(size.width * 0.42, 44), paint);

    // Pessoa direita
    canvas.drawCircle(Offset(size.width * 0.7, 8), 6, paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 14), Offset(size.width * 0.7, 30), paint);
    canvas.drawLine(
        Offset(size.width * 0.55, 22), Offset(size.width * 0.85, 22), paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 30), Offset(size.width * 0.58, 44), paint);
    canvas.drawLine(
        Offset(size.width * 0.7, 30), Offset(size.width * 0.82, 44), paint);

    // Haltere no meio
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

  const _RotinaCard({
    required this.categoria,
    required this.nome,
    required this.autor,
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
          Icon(Icons.more_vert, color: kTextGrey, size: 20),
        ],
      ),
    );
  }
}

class FitgroupBottomNav extends StatelessWidget {
  final int selectedIndex;
  const FitgroupBottomNav({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(color: kBorderGrey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            isSelected: selectedIndex == 0,
            onTap: () => Navigator.pushReplacementNamed(context, '/rotinas'),
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            isSelected: selectedIndex == 1,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.group_outlined,
            isSelected: selectedIndex == 2,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? kDarkNavy : kTextGrey,
            size: 26,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: kDarkNavy,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}