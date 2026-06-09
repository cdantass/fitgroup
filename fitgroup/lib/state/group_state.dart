import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group.dart';
import '../models/chat_message.dart';

class GroupState extends ChangeNotifier {
  static final GroupState instance = GroupState._();
  GroupState._();

  final Map<String, List<ChatMessage>> _chats = {};

  List<ChatMessage> getMessages(String groupId) => _chats[groupId] ?? [];

  void addMessage(String groupId, ChatMessage message) {
    _chats.putIfAbsent(groupId, () => []);
    _chats[groupId]!.add(message);
    notifyListeners();
  }

  List<Group> _groups = [];

  List<Group> get myGroups => _groups.where((g) => g.isJoined).toList();
  List<Group> get discoverGroups => _groups.where((g) => !g.isJoined).toList();

  Future<void> loadGroups(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    final snapshot = await FirebaseFirestore.instance
        .collection('grupos')
        .where('usuarios', arrayContains: userRef)
        .get();

    _groups = snapshot.docs.map((doc) {
      final data = doc.data();
      final adminRefs = (data['admin'] as List?)?.cast<DocumentReference>() ?? [];
      final isOwner = adminRefs.any((ref) => ref.id == uid);

      final colorValue = data['cor'] as int?;
      final color = colorValue != null ? Color(colorValue) : const Color(0xFF8B5CF6);

      return Group(
        id: doc.id,
        name: data['nome'] as String? ?? '',
        description: data['descricao'] as String? ?? '',
        color: color,
        members: (data['usuarios'] as List?)?.length ?? 1,
        isJoined: true,
        isOwner: isOwner,
      );
    }).toList();

    notifyListeners();
  }

  Future<Map<String, dynamic>?> getGroupData(String groupId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(groupId)
          .get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required Color color,
    required String userUid,
    List<String> memberUids = const [],
    List<String> adminUids = const [],
  }) async {
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc();

    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(userUid);
    final memberRefs = [userRef, ...memberUids.map((uid) => FirebaseFirestore.instance.collection('usuarios').doc(uid))];
    final adminRefs = [userRef, ...adminUids.map((uid) => FirebaseFirestore.instance.collection('usuarios').doc(uid))];

    await groupRef.set({
      'nome': name,
      'descricao': description,
      'cor': color.toARGB32(),
      'usuarios': memberRefs,
      'admin': adminRefs,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('usuarios').doc(userUid).update({
      'listaGrupos': FieldValue.arrayUnion([groupRef]),
    });

    _groups.insert(0, Group(
      id: groupRef.id,
      name: name,
      description: description,
      color: color,
      members: memberRefs.length,
      isJoined: true,
      isOwner: true,
    ));
    notifyListeners();
  }

  Future<void> updateGroup(
    String id, {
    String? name,
    String? description,
    Color? color,
    List<String> memberUids = const [],
    List<String> adminUids = const [],
  }) async {
    final gIndex = _groups.indexWhere((g) => g.id == id);
    if (gIndex == -1) return;

    final g = _groups[gIndex];
    final updatedName = name ?? g.name;
    final updatedDescription = description ?? g.description;
    final updatedColor = color ?? g.color;

    final memberRefs = memberUids.map((uid) => FirebaseFirestore.instance.collection('usuarios').doc(uid)).toList();
    final adminRefs = adminUids.map((uid) => FirebaseFirestore.instance.collection('usuarios').doc(uid)).toList();

    await FirebaseFirestore.instance.collection('grupos').doc(id).set({
      'nome': updatedName,
      'descricao': updatedDescription,
      'cor': updatedColor.toARGB32(),
      'usuarios': memberRefs,
      'admin': adminRefs,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    g.name = updatedName;
    g.description = updatedDescription;
    g.color = updatedColor;
    g.members = memberRefs.length;
    notifyListeners();
  }

  Future<void> joinGroup(String id, String userUid) async {
    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(userUid);
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);

    await groupRef.update({
      'usuarios': FieldValue.arrayUnion([userRef]),
    });

    await FirebaseFirestore.instance.collection('usuarios').doc(userUid).update({
      'listaGrupos': FieldValue.arrayUnion([groupRef]),
    });

    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = true;
    g.members++;
    notifyListeners();
  }

  Future<void> leaveGroup(String id, String userUid) async {
    final userRef = FirebaseFirestore.instance.collection('usuarios').doc(userUid);
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);

    await groupRef.update({
      'usuarios': FieldValue.arrayRemove([userRef]),
      'admin': FieldValue.arrayRemove([userRef]),
    });

    await FirebaseFirestore.instance.collection('usuarios').doc(userUid).update({
      'listaGrupos': FieldValue.arrayRemove([groupRef]),
    });

    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = false;
    if (g.members > 0) g.members--;
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);
      await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
        'listaGrupos': FieldValue.arrayRemove([groupRef]),
      });
    }

    await FirebaseFirestore.instance.collection('grupos').doc(id).delete();
    _groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
