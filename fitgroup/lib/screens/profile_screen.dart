import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  if (user.displayName != null && user.displayName!.isNotEmpty) {
    return user.displayName!.split(' ').first;
  }

  final emailPrefix = user.email?.split('@').first ?? 'usuário';
  final firstName = emailPrefix.replaceAll('.', ' ').split(' ').first;
  return firstName[0].toUpperCase() + firstName.substring(1);
}

  String get _email => _currentUser?.email ?? '';

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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _boxDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: _currentUser?.photoURL != null
                            ? NetworkImage(_currentUser!.photoURL!)
                            : null,
                        child: _currentUser?.photoURL == null
                            ? const Icon(Icons.person_outline, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _firstName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            _email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Estatísticas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                _buildStats(),
                const SizedBox(height: 24),
                const Text(
                  'Configurações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: _boxDecoration(),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: notificationsOn,
                        onChanged: (value) {
                          setState(() {
                            notificationsOn = value;
                          });
                        },
                        title: const Text('Notificações'),
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF5B4DB1),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Privacidade'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Ajuda e suporte'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final uid = _currentUser?.uid;
    if (uid == null) {
      return _statsGrid(treinos: 0, calorias: 0, recordes: 0, sequencia: 0);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                color: Color(0xFF5B4DB1),
              ),
            ),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

        return _statsGrid(
          treinos: (data['treinos'] ?? 0) as num,
          calorias: (data['calorias'] ?? 0) as num,
          recordes: (data['recordes'] ?? 0) as num,
          sequencia: (data['sequencia'] ?? 0) as num,
        );
      },
    );
  }

  Widget _statsGrid({
    required num treinos,
    required num calorias,
    required num recordes,
    required num sequencia,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.3,
      children: [
        StatBox(
          title: '$treinos',
          subtitle: 'Treinos',
          icon: Icons.fitness_center_rounded,
          iconColor: const Color(0xFF5B4DB1),
        ),
        StatBox(
          title: _formatCalorias(calorias),
          subtitle: 'Calorias',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFE25757),
        ),
        StatBox(
          title: '$recordes',
          subtitle: 'Recordes',
          icon: Icons.show_chart_rounded,
          iconColor: const Color(0xFF6A4FB3),
        ),
        StatBox(
          title: '$sequencia dias',
          subtitle: 'Sequência',
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFD0A13B),
        ),
      ],
    );
  }

  String _formatCalorias(num calorias) {
    if (calorias >= 1000) {
      return '${(calorias / 1000).toStringAsFixed(1)}k';
    }
    return '$calorias';
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Transform.scale(
                  scale: 1.9,
                  child: Image.asset(
                    'img/logo_fitgroup.png',
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
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

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

class StatBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const StatBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}