import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditrack/services/account_firestore.dart';

class UserProfileRepository {
  UserProfileRepository([this._account]);
  final AccountFirestore? _account;

  Future<Map<String, dynamic>?> load(String uid) async {
    await _account!.assertOwner(uid);
    return (await _account.user(uid).get()).data();
  }

  Future<void> save(String uid, Map<String, dynamic> fields) async {
    await _account!.assertOwner(uid);
    await _account.user(uid).set(fields, SetOptions(merge: true));
  }
}
