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
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    GroupState.instance.addListener(_rebuild);
    _syncGroupsWithFirestore();
  }

  @override
  void dispose() {
    GroupState.instance.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    _persistGroupsToFirestore();
    setState(() {});
  }

  String? _extractIdFromItem(dynamic item) {
    if (item is String) return item;
    if (item is DocumentReference) return item.id;
    if (item is Map<String, dynamic>) return item['id']?.toString();
    return null;
  }

  Future<void> _syncGroupsWithFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final rawList = data['listaGrupos'];
      if (rawList is List) {
        for (final item in rawList) {
          final id = _extractIdFromItem(item);
          if (id != null && !GroupState.instance.myGroups.any((g) => g.id == id)) {
            try {
              if ((await _db.collection('grupos').doc(id).get()).exists) {
                GroupState.instance.joinGroup(id, user.uid);
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _persistGroupsToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _db.collection('usuarios').doc(user.uid).update({
        'listaGrupos': GroupState.instance.myGroups.map((g) => g.id).toList(),
      });
    } catch (_) {}
  }

  Color _colorFromValue(dynamic value, int index) {
    if (value is int) return Color(value);
    if (value is String && value.isNotEmpty) {
      try {
        return Color(int.parse(value.replaceAll('#', '').padLeft(8, 'F'), radix: 16));
      } catch (_) {}
    }
    return kGroupColors[index % kGroupColors.length];
  }

  Group _groupFromMap(String id, Map<String, dynamic> data, int index) => Group(
        id: id,
        name: (data['nome'] ?? data['name'] ?? 'Grupo').toString(),
        description: (data['descricao'] ?? data['description'] ?? '').toString(),
        color: _colorFromValue(data['cor'] ?? data['color'], index),
        members: ((data['membros'] ?? data['members'] ?? 0) as num).toInt(),
        isJoined: true,
        isOwner: data['isOwner'] as bool? ?? data['owner'] as bool? ?? false,
      );

  List<String> _extractGroupIds(List<dynamic> raw) => raw
      .map((e) => _extractIdFromItem(e))
      .whereType<String>()
      .toList();

  List<Group> _groupsFromRawList(List<dynamic> raw) => raw
      .asMap()
      .entries
      .where((e) => e.value is Map<String, dynamic>)
      .map((e) => _groupFromMap(
            (e.value as Map<String, dynamic>)['id']?.toString() ?? 'grupo_${e.key}',
            e.value as Map<String, dynamic>,
            e.key,
          ))
      .toList();

  Future<List<Group>> _loadGroupsFromFirestore(List<String> ids, List<Group> extra) async {
    final fetched = <String, Group>{};
    try {
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, (i + 10).clamp(0, ids.length));
        final snap = await _db.collection('grupos').where(FieldPath.documentId, whereIn: chunk).get();
        for (final doc in snap.docs) {
          fetched[doc.id] = _groupFromMap(doc.id, doc.data() as Map<String, dynamic>, extra.length + fetched.length);
        }
      }
    } catch (_) {
      return extra;
    }
    return [...extra, ...ids.where(fetched.containsKey).map((id) => fetched[id]!)];
  }

  static const _sectionStyle = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E), letterSpacing: -0.3,
  );

  Widget _sectionTitle(String text, EdgeInsets padding) =>
      Padding(padding: padding, child: Text(text, style: _sectionStyle));

  Widget _loadingIndicator(EdgeInsets padding) => Padding(
        padding: padding,
        child: const CircularProgressIndicator(color: Color(0xFF5B4DB1)),
      );

  Widget _emptyText(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(msg, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
      );

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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -40,
                  child: SizedBox(
                    width: 200, height: 200,
                    child: Image.asset(
                      'img/logo_fitgroup.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 50),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
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
    const topPad = EdgeInsets.fromLTRB(20, 24, 20, 14);
    const sidePad = EdgeInsets.symmetric(horizontal: 20);

    final user = _auth.currentUser;
    if (user == null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Seus Grupos', topPad),
        _emptyText('Faça login para ver seus grupos.'),
      ]);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle('Seus Grupos', topPad),
            _loadingIndicator(sidePad),
          ]);
        }

        final data = snap.data?.data() as Map<String, dynamic>? ?? {};
        final rawList = (data['listaGrupos'] is List ? data['listaGrupos'] as List : <dynamic>[]);
        final groupIds = _extractGroupIds(rawList);
        final initialGroups = _groupsFromRawList(rawList);
        final localGroups = GroupState.instance.myGroups;

        Widget content(List<Group> groups) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Seus Grupos', topPad),
                if (groups.isEmpty)
                  _emptyText('Você ainda não entrou em nenhum grupo.')
                else
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: groups.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GroupChip(group: groups[i], onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => GroupChatScreen(group: groups[i])))),
                      ),
                    ),
                  ),
              ],
            );

        if (groupIds.isEmpty) return content(localGroups.isNotEmpty ? localGroups : initialGroups);

        return FutureBuilder<List<Group>>(
          future: _loadGroupsFromFirestore(groupIds, initialGroups),
          builder: (context, groupsSnap) {
            if (groupsSnap.connectionState == ConnectionState.waiting) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionTitle('Seus Grupos', topPad),
                _loadingIndicator(sidePad),
              ]);
            }
            final groups = groupsSnap.data;
            return content(groups == null || groups.isEmpty
                ? (localGroups.isNotEmpty ? localGroups : initialGroups)
                : groups);
          },
        );
      },
    );
  }

  Widget _buildWorkouts(BuildContext context) {
    const topPad = EdgeInsets.fromLTRB(20, 20, 20, 14);
    const sidePad = EdgeInsets.symmetric(horizontal: 20);

    Widget header({bool loading = false, String? msg}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Seus treinos', topPad),
            if (loading) _loadingIndicator(sidePad),
            if (msg != null) _emptyText(msg),
          ],
        );

    final user = _auth.currentUser;
    if (user == null) return header(msg: 'Faça login para ver seus treinos.');

    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('usuarios').doc(user.uid).snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return header(loading: true);
        if (!snap.hasData || snap.data == null) return header(msg: 'Nenhum treino encontrado.');

        final data = snap.data!.data() as Map<String, dynamic>;
        final rotinaIds = List<String>.from(data['listaRotinas'] ?? []);
        if (rotinaIds.isEmpty) return header(msg: 'Você ainda não tem treinos. Crie um treino para começar!');

        return StreamBuilder<QuerySnapshot>(
          stream: _db.collection('rotinas').where(FieldPath.documentId, whereIn: rotinaIds).snapshots(),
          builder: (context, rotinaSnap) {
            if (rotinaSnap.connectionState == ConnectionState.waiting) return header(loading: true);
            if (!rotinaSnap.hasData || rotinaSnap.data!.docs.isEmpty) return header(msg: 'Nenhum treino encontrado.');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Seus treinos', topPad),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rotinaSnap.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = rotinaSnap.data!.docs[index];
                    final rotinaData = doc.data() as Map<String, dynamic>;
                    final exercisesData = List<Map<String, dynamic>>.from(rotinaData['exercicios'] ?? []);
                    final exercises = exercisesData.map((ex) => Exercise(
                          name: ex['nome'] ?? 'Exercício',
                          series: ex['series'] ?? 3,
                          reps: ex['repeticoes'] ?? ex['reps'] ?? 10,
                          weight: (ex['peso'] ?? 0).toDouble(),
                          hasWeight: ex['temPeso'] ?? ((ex['peso'] ?? 0) > 0),
                          durationMinutes: ex['duracao'],
                          completed: ex['completo'] ?? false,
                        )).toList();

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
                          MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: workout)),
                        ).then((_) => setState(() {})),
                        onExerciseToggle: (i) async {
                          final updated = List<Map<String, dynamic>>.from(exercisesData);
                          updated[i] = {...updated[i], 'completo': !exercises[i].completed};
                          try {
                            await _db.collection('rotinas').doc(doc.id).update({'exercicios': updated});
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
                          }
                        },
                        onDelete: () async {
                          try {
                            await _db.collection('rotinas').doc(doc.id).delete();
                            await _db.collection('usuarios').doc(user.uid).update({
                              'listaRotinas': FieldValue.arrayRemove([doc.id]),
                            });
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Treino excluído com sucesso')));
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
                          }
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
