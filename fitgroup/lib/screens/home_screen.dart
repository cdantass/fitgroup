import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_data.dart';
import '../models/group.dart';
import '../state/group_state.dart';
import '../theme/app_theme.dart';
import '../widgets/workout_card.dart';
import '../widgets/group_chip.dart';
import 'workout_detail_screen.dart';
import 'profile_screen.dart';
import 'group_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    GroupState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    GroupState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _openChat(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroups(context),
                    const SizedBox(height: 8),
                    _buildWorkouts(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryDark,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -40,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'img/logo_fitgroup.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
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

  Widget _buildGroups(BuildContext context) {
    final myGroups = GroupState.instance.myGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Text(
            'Seus Grupos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (myGroups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Você ainda não entrou em nenhum grupo.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: myGroups.length,
              itemBuilder: (context, index) {
                final group = myGroups[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GroupChip(
                    group: group,
                    onTap: () => _openChat(group),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildWorkouts(BuildContext context) {
    final user = _auth.currentUser;
    
    if (user == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Text(
              'Seus treinos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Faça login para ver seus treinos.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Text(
                  'Seus treinos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CircularProgressIndicator(
                  color: Color(0xFF5B4DB1),
                ),
              ),
            ],
          );
        }

        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Text(
                  'Seus treinos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Nenhum treino encontrado.',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ],
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final rotinaIds = List<String>.from(userData['listaRotinas'] ?? []);

        if (rotinaIds.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                child: Text(
                  'Seus treinos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Você ainda não tem treinos. Crie um treino para começar!',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                ),
              ),
            ],
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _db
              .collection('rotinas')
              .where(FieldPath.documentId, whereIn: rotinaIds)
              .snapshots(),
          builder: (context, rotinaSnapshot) {
            if (rotinaSnapshot.connectionState == ConnectionState.waiting) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Text(
                      'Seus treinos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B4DB1),
                    ),
                  ),
                ],
              );
            }

            if (!rotinaSnapshot.hasData || rotinaSnapshot.data!.docs.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Text(
                      'Seus treinos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Nenhum treino encontrado.',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ),
                ],
              );
            }

            final rotinas = rotinaSnapshot.data!.docs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Text(
                    'Seus treinos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rotinas.length,
                  itemBuilder: (context, index) {
                    final rotinaDoc = rotinas[index];
                    final rotinaData = rotinaDoc.data() as Map<String, dynamic>;
                    
                    // Convertendo dados do Firestore para Workout
                    final exercisesData = List<Map<String, dynamic>>.from(
                      rotinaData['exercicios'] ?? [],
                    );
                    final exercises = exercisesData.map((ex) {
                      return Exercise(
                        name: ex['nome'] ?? 'Exercício',
                        series: ex['series'] ?? 3,
                        reps: ex['repeticoes'] ?? ex['reps'] ?? 10,
                        weight: (ex['peso'] ?? 0).toDouble(),
                        hasWeight: ex['temPeso'] ?? ((ex['peso'] ?? 0) > 0),
                        durationMinutes: ex['duracao'],
                        completed: ex['completo'] ?? false,
                      );
                    }).toList();

                    final workout = Workout(
                      title: rotinaData['nome'] ?? 'Treino',
                      subtitle: rotinaData['tipo'] ?? 'Treino completo',
                      estimatedMinutes: rotinaData['duracao'] ?? 45,
                      exercises: exercises,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: WorkoutCard(
                        workout: workout,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutDetailScreen(workout: workout),
                          ),
                        ).then((_) => setState(() {})),
                        onExerciseToggle: (exerciseIndex) {
                          setState(() {
                            exercises[exerciseIndex].completed =
                                !exercises[exerciseIndex].completed;
                          });
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}