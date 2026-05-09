import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'img/logo_fitgroup.png',
                height: 80,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'João', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        'joao@gmail.com', 
                        style: TextStyle(color: Colors.grey)
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              'Estatísticas', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey)
            ),
            const SizedBox(height: 10),
            
            Row(
              children: [
                _buildStatCard('48', 'Treinos'),
                const SizedBox(width: 10),
                _buildStatCard('45.5k', 'Calorias'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard('7', 'Recordes'),
                const SizedBox(width: 10),
                _buildStatCard('14 dias', 'Sequência'),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              'Configurações', 
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey)
            ),
            const SizedBox(height: 10),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildListTile('Notificações'),
                  const Divider(height: 1),
                  _buildListTile('Privacidade'),
                  const Divider(height: 1),
                  _buildListTile('Ajuda e suporte'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text('Voltar para Home', style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
  Widget _buildListTile(String title) {
    return ListTile(
      title: Text(title),
    );
  }
}