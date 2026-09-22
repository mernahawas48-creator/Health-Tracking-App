import 'package:meditrack/services/account_firestore.dart';

class NotificationStateRepository {
  NotificationStateRepository(this._account);
  final AccountFirestore _account;

  Future<bool> isRead() async {
    final uid = _account.uid;
    final doc = await _account
        .user(uid)
        .collection('notificationState')
        .doc('inbox')
        .get();
    await _account.assertOwner(uid);
    return doc.data()?['read'] as bool? ?? false;
  }

  Future<void> markRead() async {
    final uid = _account.uid;
    await _account.user(uid).collection('notificationState').doc('inbox').set({
      'read': true,
    });
  }
}
