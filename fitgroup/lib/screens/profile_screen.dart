import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notificationsOn = true;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String get _firstName {
    final user = _currentUser;
    if (user == null) return 'Usuário';
    if (user.displayName?.isNotEmpty == true) return user.displayName!.split(' ').first;
    final prefix = user.email?.split('@').first ?? 'usuário';
    final name = prefix.replaceAll('.', ' ').split(' ').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  String get _email => _currentUser?.email ?? '';

  static BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      );

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Política de Privacidade'),
        content: SingleChildScrollView(
          child: Text(
            'Nós respeitamos sua privacidade. Seus dados pessoais são usados apenas para '
            'melhorar sua experiência no FitGroup e nunca são compartilhados com terceiros sem seu consentimento.\n\n'
            'Os dados de treino são armazenados de forma segura nos servidores protegidos do Firebase. '
            'Você pode solicitar a exclusão de seus dados a qualquer momento entrando em contato conosco.\n\n'
            'Para mais informações, entre em contato: caua.dantas@souunit.com.br',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B4DB1), foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildUserCard(),
                const SizedBox(height: 24),
                _sectionLabel('Estatísticas'),
                const SizedBox(height: 12),
                _buildStats(),
                const SizedBox(height: 24),
                _sectionLabel('Configurações'),
                const SizedBox(height: 12),
                _buildSettings(),
                const SizedBox(height: 30),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
      );

  Widget _buildUserCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(_currentUser?.uid).snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data() as Map<String, dynamic>?;
        final name = (data?['nome'] as String?)?.trim().isNotEmpty == true ? data!['nome'] as String : _firstName;
        final email = (data?['email'] as String?)?.trim().isNotEmpty == true ? data!['email'] as String : _email;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration,
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: _currentUser?.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
                child: _currentUser?.photoURL == null ? const Icon(Icons.person_outline, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  Text(email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    final uid = _currentUser?.uid;
    if (uid == null) return _statsGrid(treinos: 0, calorias: 0, recordes: 0, sequencia: 0);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(color: Color(0xFF5B4DB1)),
          ));
        }
        if (!snap.hasData || snap.data == null) return _statsGrid(treinos: 0, calorias: 0, recordes: 0, sequencia: 0);

        final data = snap.data!.data() as Map<String, dynamic>? ?? {};
        final rotinas = List<String>.from(data['listaRotinas'] ?? []);
        final calorias = (data['calorias'] ?? 0) as num;
        final recordes = (data['recordes'] ?? 0) as num;
        final sequencia = (data['sequencia'] ?? 0) as num;

        if (rotinas.isEmpty) return _statsGrid(treinos: 0, calorias: calorias, recordes: recordes, sequencia: sequencia);

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('rotinas').where(FieldPath.documentId, whereIn: rotinas).get(),
          builder: (context, rotinaSnap) {
            if (rotinaSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(color: Color(0xFF5B4DB1)),
              ));
            }
            return _statsGrid(treinos: rotinas.length, calorias: calorias, recordes: recordes, sequencia: sequencia);
          },
        );
      },
    );
  }

  Widget _statsGrid({required num treinos, required num calorias, required num recordes, required num sequencia}) {
    String fmt(num v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v';
    return GridView.count(
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 2.3,
      children: [
        StatBox(title: '$treinos', subtitle: 'Treinos', icon: Icons.fitness_center_rounded, iconColor: const Color(0xFF5B4DB1)),
        StatBox(title: fmt(calorias), subtitle: 'Calorias', icon: Icons.local_fire_department_rounded, iconColor: const Color(0xFFE25757)),
        StatBox(title: '$recordes', subtitle: 'Recordes', icon: Icons.show_chart_rounded, iconColor: const Color(0xFF6A4FB3)),
        StatBox(title: '$sequencia dias', subtitle: 'Sequência', icon: Icons.emoji_events_rounded, iconColor: const Color(0xFFD0A13B)),
      ],
    );
  }

  Widget _buildSettings() {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          SwitchListTile(
            value: notificationsOn,
            onChanged: (v) => setState(() => notificationsOn = v),
            title: const Text('Notificações'),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF5B4DB1),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Privacidade'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _showPrivacyDialog,
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Ajuda e suporte'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent, foregroundColor: Colors.white,
          elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        child: const Text('Sair', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF09152B),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 90,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Transform.scale(
                  scale: 1.9,
                  child: Image.asset(
                    'img/logo_fitgroup.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const StatBox({super.key, required this.title, required this.subtitle, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
