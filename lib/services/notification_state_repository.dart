import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalAlert {
  const LocalAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool read;

  LocalAlert copyWith({bool? read}) => LocalAlert(
    id: id,
    title: title,
    body: body,
    type: type,
    createdAt: createdAt,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'read': read,
  };

  factory LocalAlert.fromJson(Map<String, dynamic> json) => LocalAlert(
    id: json['id'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    type: json['type'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    read: json['read'] as bool? ?? false,
  );
}

class NotificationStateRepository {
  static const _storageKey = 'notification_center_records_v1';

  Future<List<LocalAlert>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_storageKey) ?? const [];
    final alerts = <LocalAlert>[];
    for (final value in raw) {
      try {
        alerts.add(
          LocalAlert.fromJson(jsonDecode(value) as Map<String, dynamic>),
        );
      } catch (_) {
        // One malformed record should not hide useful alert history.
      }
    }
    alerts.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return alerts;
  }

  Future<void> add(LocalAlert alert) async {
    final alerts = await load();
    final withoutDuplicate = alerts
        .where((item) => item.id != alert.id)
        .toList();
    await _save([alert, ...withoutDuplicate]);
  }

  Future<void> markRead(String id) async {
    final alerts = await load();
    await _save([
      for (final alert in alerts)
        if (alert.id == id) alert.copyWith(read: true) else alert,
    ]);
  }

  Future<void> markAllRead() async {
    final alerts = await load();
    await _save([for (final alert in alerts) alert.copyWith(read: true)]);
  }

  Future<void> _save(List<LocalAlert> alerts) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      alerts.map((alert) => jsonEncode(alert.toJson())).toList(),
    );
  }
}
