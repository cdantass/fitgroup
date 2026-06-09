import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group.dart';

class GroupState extends ChangeNotifier {
  static final GroupState instance = GroupState._();
  GroupState._();

  List<Group> _groups = [];
  String? _currentUserUid;
  String? _currentUserEmail;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Group> get myGroups => _groups.where((g) => g.isJoined).toList();
  List<Group> get discoverGroups => _groups.where((g) => !g.isJoined).toList();

  DocumentReference _userRef(String uid) =>
      FirebaseFirestore.instance.collection('usuarios').doc(uid);

  // Suporta DocumentReference, UID string e email string (dados legados)
  bool _uidInList(List<dynamic> list, String uid) {
    final email = _currentUserEmail;
    return list.any((item) =>
        (item is DocumentReference && item.id == uid) ||
        (item is String && item == uid) ||
        (email != null && item is String && item == email));
  }

  Future<void> loadGroups(String uid) async {
    _currentUserUid = uid;
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('grupos').get();

      _groups = snapshot.docs.map((doc) {
        final data = doc.data();
        final usuariosRaw = (data['usuarios'] as List?) ?? [];
        final adminRaw = [
          ...((data['admin'] as List?) ?? []),
          ...((data['admins'] as List?) ?? []),
        ];
        final colorValue = data['cor'] as int?;
        return Group(
          id: doc.id,
          name: data['nome'] as String? ?? '',
          description: data['descricao'] as String? ?? '',
          color: colorValue != null ? Color(colorValue) : kGroupColors.first,
          members: usuariosRaw.length,
          isJoined: _uidInList(usuariosRaw, uid),
          isOwner: _uidInList(adminRaw, uid),
        );
      }).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> joinGroup(String id, String userUid) async {
    final userRef = _userRef(userUid);
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);

    await groupRef.update({
      'usuarios': FieldValue.arrayUnion([userRef]),
    });
    try {
      await userRef.update({
        'listaGrupos': FieldValue.arrayUnion([groupRef]),
      });
    } catch (_) {}

    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = true;
    g.members++;
    notifyListeners();
  }

  Future<void> leaveGroup(String id, String userUid) async {
    final userRef = _userRef(userUid);
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);
    final email = _currentUserEmail;
    final toRemove = [userRef, if (email != null) email];

    await groupRef.update({
      'usuarios': FieldValue.arrayRemove(toRemove),
      'admin': FieldValue.arrayRemove(toRemove),
      'admins': FieldValue.arrayRemove(toRemove),
    });
    try {
      await userRef.update({
        'listaGrupos': FieldValue.arrayRemove([groupRef]),
      });
    } catch (_) {}

    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = false;
    if (g.members > 0) g.members--;
    notifyListeners();
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
    final userRef = _userRef(userUid);

    final allMemberUids = {userUid, ...memberUids}.toList();
    final allAdminUids = {userUid, ...adminUids}.toList();

    final memberRefs = allMemberUids.map(_userRef).toList();
    final adminRefs = allAdminUids.map(_userRef).toList();

    await groupRef.set({
      'nome': name,
      'descricao': description,
      'cor': color.toARGB32(),
      'usuarios': memberRefs,
      'admin': adminRefs,
      'criado_por': _currentUserEmail ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await userRef.update({
        'listaGrupos': FieldValue.arrayUnion([groupRef]),
      });
    } catch (_) {}

    _groups.insert(
        0,
        Group(
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
    List<String>? usuarios,
    List<String>? admins,
  }) async {
    final gIndex = _groups.indexWhere((g) => g.id == id);
    if (gIndex == -1) return;

    final g = _groups[gIndex];
    final updatedName = name ?? g.name;
    final updatedDescription = description ?? g.description;
    final updatedColor = color ?? g.color;

    final Map<String, dynamic> data = {
      'nome': updatedName,
      'descricao': updatedDescription,
      'cor': updatedColor.toARGB32(),
      'atualizado_por': FirebaseAuth.instance.currentUser?.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (usuarios != null) {
      data['usuarios'] = usuarios.map(_userRef).toList();
    }
    if (admins != null) {
      data['admin'] = admins.map(_userRef).toList();
    }

    await FirebaseFirestore.instance
        .collection('grupos')
        .doc(id)
        .set(data, SetOptions(merge: true));

    g.name = updatedName;
    g.description = updatedDescription;
    g.color = updatedColor;
    if (usuarios != null) g.members = usuarios.length;
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    final uid = _currentUserUid;
    final groupRef = FirebaseFirestore.instance.collection('grupos').doc(id);

    if (uid != null) {
      try {
        await _userRef(uid).update({
          'listaGrupos': FieldValue.arrayRemove([groupRef]),
        });
      } catch (_) {}
    }

    await groupRef.delete();
    _groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
