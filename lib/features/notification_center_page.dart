import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/services/notification_state_repository.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:meditrack/themes/appcolors.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});
  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  List<LocalAlert> _alerts = const [];
  NotificationStateRepository get _repository =>
      getIt<NotificationStateRepository>();
  Future<void> _load() async {
    final alerts = await _repository.load();
    if (mounted) setState(() => _alerts = alerts);
  }

  Future<void> _markAll() async {
    await _repository.markAllRead();
    await _load();
  }

  Future<void> _markRead(String id) async {
    await _repository.markRead(id);
    await _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppStrings.of(context).isArabic;
    return Scaffold(
      appBar: AppBar(
        title: Text(ar ? 'التنبيهات' : 'Notifications'),
        actions: [
          TextButton(
            onPressed: _markAll,
            child: Text(ar ? 'تحديد الكل كمقروء' : 'Mark all read'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _alerts.isEmpty
            ? [
                Center(
                  child: Text(
                    ar ? 'لا توجد تنبيهات محفوظة.' : 'No saved alerts yet.',
                  ),
                ),
              ]
            : [
                for (final alert in _alerts)
                  Card(
                    color: alert.read
                        ? context.appSurface
                        : context.appMutedSurface,
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Appcolors.SecondaryOrange,
                      ),
                      title: Text(alert.title),
                      subtitle: Text(alert.body),
                      trailing: alert.read
                          ? null
                          : Icon(
                              Icons.circle,
                              size: 10,
                              color: Appcolors.SecondaryOrange,
                            ),
                      onTap: () => _markRead(alert.id),
                    ),
                  ),
              ],
      ),
    );
  }
}
