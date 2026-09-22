import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Resolves the account at each operation. Never caches a previous user's UID.
class AccountFirestore {
  AccountFirestore({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    String? Function()? uidProvider,
  }) : _providedAuth = auth,
       _providedFirestore = firestore,
       _uidProvider = uidProvider;

  final FirebaseAuth? _providedAuth;
  final FirebaseFirestore? _providedFirestore;
  final String? Function()? _uidProvider;
  FirebaseAuth get _auth => _providedAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _providedFirestore ?? FirebaseFirestore.instance;

  String get uid {
    final value = _uidProvider != null
        ? _uidProvider()
        : _auth.currentUser?.uid;
    if (value == null) throw StateError('No authenticated account.');
    return value;
  }

  DocumentReference<Map<String, dynamic>> user(String ownerUid) =>
      _firestore.collection('users').doc(ownerUid);

  CollectionReference<Map<String, dynamic>> ownedCollection(String name) =>
      user(uid).collection(name);

  Future<void> assertOwner(String ownerUid) async {
    if (uid != ownerUid) throw StateError('Account changed during operation.');
  }
}
