import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  Future<void> syncUserToFirestore(User user, String provider) async {
    if (user.uid.isEmpty) return;
    final docRef = _db.collection('usuarios').doc(user.uid);

    try {
      final snapshot = await docRef.get();

      final updateData = {
        'uid': user.uid,
        'nome': user.displayName ?? '',
        'email': user.email ?? '',
        'fotoUrl': user.photoURL ?? '',
        'provider': provider,
        'updatedAt': Timestamp.now(),
      };

      if (!snapshot.exists) {
        final createData = {
          ...updateData,
          'listaGrupos': <dynamic>[],
          'listaRotinas': <dynamic>[],
          'criado_por': user.email ?? '',
          'createdAt': Timestamp.now(),
        };
        await docRef.set(createData);
      } else {
        await docRef.update(updateData);
      }
    } catch (e) {
      // Propaga para o chamador tratar (UI, logs, etc.)
      rethrow;
    }
  }
}
