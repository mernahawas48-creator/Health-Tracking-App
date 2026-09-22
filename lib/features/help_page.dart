import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const topics = <(String, String)>[
    (
      'Getting started',
      'Set goals in Profile, then use Home cards to log your day.',
    ),
    ('Medications', 'Add medicines and mark doses Taken or Skipped.'),
    ('Nutrition', 'Search foods and review calories and macros.'),
    ('Water and sleep', 'Log progress and manage reminders in Settings.'),
    ('Activity', 'Steps and distance are ready for device integration later.'),
    ('Notifications', 'Open the bell on Home to view reminders.'),
    ('AI Assistant', 'Use it for general habit guidance, not diagnosis.'),
    ('Profile', 'Update your details, goals, and preferences.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Help and support')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: topics
          .map(
            (topic) => Card(
              child: ExpansionTile(
                iconColor: Appcolors.Primary,
                title: Text(
                  topic.$1,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(topic.$2),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );
}
