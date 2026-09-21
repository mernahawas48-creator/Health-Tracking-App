import 'package:flutter/material.dart';
import 'package:meditrack/features/settings_page.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/appcolors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.initialName,
    required this.onNameChanged,
  });

  final String initialName;
  final ValueChanged<String> onNameChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _name;
  String _healthGoal = 'Build healthy habits';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<_ProfileEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _EditProfilePage(initialName: _name, initialGoal: _healthGoal),
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _name = result.name;
      _healthGoal = result.goal;
    });
    widget.onNameChanged(_name);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = AppSettingsScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _ProfileHeader(name: _name, onEdit: _openEditProfile),
            const SizedBox(height: 22),
            const Text(
              'Your health plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: settingsController,
              builder: (context, _) => _HealthPlanCard(
                goal: _healthGoal,
                waterGoalMl: settingsController.settings.waterGoalMl,
                sleepGoalMinutes: settingsController.settings.sleepGoalMinutes,
                activeCaloriesGoal:
                    settingsController.settings.activeCaloriesGoal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal details',
                  subtitle: 'Name and health goal',
                  onTap: _openEditProfile,
                ),
                _SettingsDivider(),
                _NotificationTile(
                  enabled: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  title: 'App settings',
                  subtitle: 'Goals, theme, language and units',
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SettingsPage(controller: settingsController),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help and support',
                  onTap: () => _showComingSoon('Help and support'),
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy',
                  onTap: () => _showComingSoon('Privacy settings'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showComingSoon('Sign out'),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Appcolors.SecondaryOrange,
                side: const BorderSide(color: Appcolors.SecondaryOrange),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Health Tracking App',
                style: TextStyle(color: Appcolors.Grey2, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.onEdit});

  final String name;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolors.Primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xffE8DFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xff5C42A5),
              size: 38,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Appcolors.White,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Your wellness journey',
                  style: TextStyle(color: Color(0xffD8F6F7)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Appcolors.White),
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }
}

class _HealthPlanCard extends StatelessWidget {
  const _HealthPlanCard({
    required this.goal,
    required this.waterGoalMl,
    required this.sleepGoalMinutes,
    required this.activeCaloriesGoal,
  });

  final String goal;
  final int waterGoalMl;
  final int sleepGoalMinutes;
  final int activeCaloriesGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Appcolors.White,
        border: Border.all(color: Appcolors.Grey3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xffE3F7F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Appcolors.Primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Main goal',
                      style: TextStyle(color: Appcolors.Grey2, fontSize: 13),
                    ),
                    Text(
                      goal,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _GoalValue(
                  value: '${waterGoalMl / 1000} L',
                  label: 'Water goal',
                ),
              ),
              Expanded(
                child: _GoalValue(
                  value: '${sleepGoalMinutes / 60} h',
                  label: 'Sleep goal',
                ),
              ),
              Expanded(
                child: _GoalValue(
                  value: '$activeCaloriesGoal',
                  label: 'Active kcal',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalValue extends StatelessWidget {
  const _GoalValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Appcolors.Primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Appcolors.Grey2, fontSize: 12),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Appcolors.White,
        border: Border.all(color: Appcolors.Grey3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 70),
      child: Divider(height: 1),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _SettingIcon(icon: icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: const TextStyle(color: Appcolors.Grey2)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const _SettingIcon(icon: Icons.notifications_none_rounded),
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        enabled ? 'Medication and daily reminders' : 'Notifications are off',
        style: const TextStyle(color: Appcolors.Grey2),
      ),
      trailing: Switch(
        value: enabled,
        activeColor: Appcolors.Primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xffE3F7F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Appcolors.Primary),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({required this.name, required this.goal});

  final String name;
  final String goal;
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({
    required this.initialName,
    required this.initialGoal,
  });

  final String initialName;
  final String initialGoal;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _nameController;
  late String _selectedGoal;

  static const _goals = [
    'Build healthy habits',
    'Improve sleep',
    'Stay active',
    'Eat healthier',
    'Manage medications',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedGoal = widget.initialGoal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name.')));
      return;
    }
    Navigator.pop(context, _ProfileEditResult(name: name, goal: _selectedGoal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        title: const Text(
          'Edit profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                filled: true,
                fillColor: Appcolors.White,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Appcolors.Grey3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Appcolors.Grey3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Appcolors.Primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What is your main goal?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._goals.map(
              (goal) => RadioListTile<String>(
                value: goal,
                groupValue: _selectedGoal,
                activeColor: Appcolors.Primary,
                contentPadding: EdgeInsets.zero,
                title: Text(goal),
                onChanged: (value) => setState(() => _selectedGoal = value!),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Appcolors.Primary,
                  foregroundColor: Appcolors.White,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
