import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meditrack/features/settings_page.dart';
import 'package:meditrack/features/reports_page.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
  }

  Future<void> _openIdentityEditor() async {
    final settingsController = AppSettingsScope.of(context);
    final result = await Navigator.push<_IdentityEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) => _EditIdentityPage(
          initialName: _name,
          initialProfileImagePath: settingsController.settings.profileImagePath,
        ),
      ),
    );

    if (result == null || !mounted) return;
    setState(() => _name = result.name);
    widget.onNameChanged(_name);
    await settingsController.update(
      settingsController.settings.copyWith(
        profileImagePath: result.profileImagePath,
      ),
    );
  }

  Future<void> _openHealthDetails() async {
    final settingsController = AppSettingsScope.of(context);
    final result = await Navigator.push<_ProfileEditResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _EditProfilePage(
              initialGoals: settingsController.settings.healthGoals,
              initialAge: settingsController.settings.age,
              initialGender: settingsController.settings.gender,
              initialHeightCm: settingsController.settings.heightCm,
              initialWeightKg: settingsController.settings.weightKg,
            ),
      ),
    );

    if (result == null || !mounted) return;
    await settingsController.update(
      settingsController.settings.copyWith(
        healthGoals: result.goals,
        age: result.age,
        gender: result.gender,
        heightCm: result.heightCm,
        weightKg: result.weightKg,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text('$feature ${AppStrings.of(context).text('comingSoon')}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final settingsController = AppSettingsScope.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          strings.text('profile'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _ProfileHeader(
              name: _name,
              imagePath: settingsController.settings.profileImagePath,
              onEdit: _openIdentityEditor,
            ),
            const SizedBox(height: 22),
            Text(
              strings.text('healthPlan'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: settingsController,
              builder: (context, _) => _HealthPlanCard(
                goals: settingsController.settings.healthGoals,
                waterGoalMl: settingsController.settings.waterGoalMl,
                sleepGoalMinutes: settingsController.settings.sleepGoalMinutes,
                activeCaloriesGoal:
                    settingsController.settings.activeCaloriesGoal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.text('preferences'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.insights_outlined,
                  title: 'Reports and streaks',
                  subtitle: 'Your weekly health summary',
                  onTap: () => Navigator.push<void>(context, MaterialPageRoute(builder: (_) => ReportsPage(medications: const [], settings: settingsController.settings))),
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: strings.text('personalDetails'),
                  subtitle: '${strings.text('age')}, ${strings.text('gender')}, '
                      '${strings.text('height')} & ${strings.text('weight')}',
                  onTap: _openHealthDetails,
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
                  title: strings.text('appSettings'),
                  subtitle: strings.text('settingsDescription'),
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
            Text(
              strings.text('support'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: strings.text('helpSupport'),
                  onTap: () => _showComingSoon(strings.text('helpSupport')),
                ),
                _SettingsDivider(),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: strings.text('privacy'),
                  onTap: () => _showComingSoon(strings.text('privacy')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showComingSoon(strings.text('signOut')),
              icon: const Icon(Icons.logout_rounded),
              label: Text(strings.text('signOut')),
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
            Center(
              child: Text(
                strings.text('healthTrackingApp'),
                style: const TextStyle(color: Appcolors.Grey2, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.imagePath,
    required this.onEdit,
  });

  final String name;
  final String? imagePath;
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
            clipBehavior: Clip.antiAlias,
            child: imagePath != null && File(imagePath!).existsSync()
                ? Image.file(File(imagePath!), fit: BoxFit.cover)
                : const Icon(
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
                Text(
                  AppStrings.of(context).text('wellnessJourney'),
                  style: const TextStyle(color: Color(0xffD8F6F7)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Appcolors.White),
            tooltip: AppStrings.of(context).text('editProfile'),
          ),
        ],
      ),
    );
  }
}

class _HealthPlanCard extends StatelessWidget {
  const _HealthPlanCard({
    required this.goals,
    required this.waterGoalMl,
    required this.sleepGoalMinutes,
    required this.activeCaloriesGoal,
  });

  final List<String> goals;
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
                    Text(
                      AppStrings.of(context).text('healthFocus'),
                      style: const TextStyle(color: Appcolors.Grey2, fontSize: 13),
                    ),
                    Text(
                      goals.isEmpty
                          ? AppStrings.of(context).text('noGoalsSelected')
                          : _focusMessage(context, goals.first),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (goals.isNotEmpty) ...[
            const SizedBox(height: 14),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goals
                    .map(
                      (goal) => Chip(
                        avatar: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: Appcolors.Primary,
                        ),
                        label: Text(_localizedGoal(context, goal)),
                        backgroundColor: const Color(0xffE3F7F8),
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _GoalValue(
                  value: '${waterGoalMl / 1000} L',
                  label: AppStrings.of(context).text('waterGoal'),
                ),
              ),
              Expanded(
                child: _GoalValue(
                  value: '${sleepGoalMinutes / 60} h',
                  label: AppStrings.of(context).text('sleepGoal'),
                ),
              ),
              Expanded(
                child: _GoalValue(
                  value: '$activeCaloriesGoal',
                  label: AppStrings.of(context).text('activeKcal'),
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
      title: Text(
        AppStrings.of(context).text('notifications'),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        enabled
            ? AppStrings.of(context).text('notificationDescription')
            : AppStrings.of(context).text('notificationsOff'),
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
  const _ProfileEditResult({
    required this.goals,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
  });

  final List<String> goals;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
}

class _IdentityEditResult {
  const _IdentityEditResult({
    required this.name,
    required this.profileImagePath,
  });

  final String name;
  final String? profileImagePath;
}

class _EditIdentityPage extends StatefulWidget {
  const _EditIdentityPage({
    required this.initialName,
    required this.initialProfileImagePath,
  });

  final String initialName;
  final String? initialProfileImagePath;

  @override
  State<_EditIdentityPage> createState() => _EditIdentityPageState();
}

class _EditIdentityPageState extends State<_EditIdentityPage> {
  late final TextEditingController _nameController;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _profileImagePath = widget.initialProfileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image != null && mounted) {
      setState(() => _profileImagePath = image.path);
    }
  }

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Appcolors.White,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.of(context).text('profilePhoto'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Appcolors.Primary),
                title: Text(AppStrings.of(context).text('takePhoto')),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Appcolors.Primary),
                title: Text(AppStrings.of(context).text('chooseFromGallery')),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source != null && mounted) await _pickProfileImage(source);
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).text('enterNameError'))),
      );
      return;
    }
    Navigator.pop(
      context,
      _IdentityEditResult(name: name, profileImagePath: _profileImagePath),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF9F7FB),
    appBar: AppBar(
      backgroundColor: Appcolors.White,
      foregroundColor: Appcolors.Black,
      elevation: 0,
      title: Text(
        AppStrings.of(context).text('editProfile'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            InkWell(
              onTap: _showImageSourcePicker,
              borderRadius: BorderRadius.circular(56),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xffE3F7F8),
                    backgroundImage:
                        _profileImagePath != null &&
                            File(_profileImagePath!).existsSync()
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null ||
                            !File(_profileImagePath!).existsSync()
                        ? const Icon(
                            Icons.person_rounded,
                            size: 54,
                            color: Appcolors.Primary,
                          )
                        : null,
                  ),
                  PositionedDirectional(
                    end: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Appcolors.Primary,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Appcolors.White,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.of(context).text('yourName'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: AppStrings.of(context).text('enterName'),
                filled: true,
                fillColor: Appcolors.White,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Appcolors.Grey3),
                ),
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
                child: Text(
                  AppStrings.of(context).text('saveChanges'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EditProfilePage extends StatefulWidget {
  const _EditProfilePage({
    required this.initialGoals,
    required this.initialAge,
    required this.initialGender,
    required this.initialHeightCm,
    required this.initialWeightKg,
  });

  final List<String> initialGoals;
  final int? initialAge;
  final String? initialGender;
  final double? initialHeightCm;
  final double? initialWeightKg;

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late Set<String> _selectedGoals;
  String? _gender;

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
    _ageController = TextEditingController(text: widget.initialAge?.toString() ?? '');
    _heightController = TextEditingController(
      text: widget.initialHeightCm?.toStringAsFixed(0) ?? '',
    );
    _weightController = TextEditingController(
      text: widget.initialWeightKg?.toStringAsFixed(1) ?? '',
    );
    _selectedGoals = widget.initialGoals.toSet();
    _gender = widget.initialGender;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final age = int.tryParse(_ageController.text.trim());
    final heightCm = double.tryParse(_heightController.text.trim());
    final weightKg = double.tryParse(_weightController.text.trim());
    if (age == null ||
        age < 1 ||
        age > 120 ||
        _gender == null ||
        heightCm == null ||
        heightCm < 50 ||
        heightCm > 250 ||
        weightKg == null ||
        weightKg < 15 ||
        weightKg > 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).text('invalidPersonalInfo'))),
      );
      return;
    }
    Navigator.pop(
      context,
      _ProfileEditResult(
        goals: _selectedGoals.toList(),
        age: age,
        gender: _gender!,
        heightCm: heightCm,
        weightKg: weightKg,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        title: Text(
          AppStrings.of(context).text('personalDetails'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.of(context).text('personalInformation'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _PersonalField(
              controller: _ageController,
              label: AppStrings.of(context).text('age'),
              suffix: AppStrings.of(context).text('years'),
              icon: Icons.cake_outlined,
              decimal: false,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: Appcolors.Primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.of(context).text('gender'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _GenderChoice(
                  label: AppStrings.of(context).text('female'),
                  selected: _gender == 'female',
                  onSelected: () => setState(() => _gender = 'female'),
                ),
                _GenderChoice(
                  label: AppStrings.of(context).text('male'),
                  selected: _gender == 'male',
                  onSelected: () => setState(() => _gender = 'male'),
                ),
                _GenderChoice(
                  label: AppStrings.of(context).text('preferNotToSay'),
                  selected: _gender == 'preferNotToSay',
                  onSelected: () =>
                      setState(() => _gender = 'preferNotToSay'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PersonalField(
                    controller: _heightController,
                    label: AppStrings.of(context).text('height'),
                    suffix: AppStrings.of(context).text('cm'),
                    icon: Icons.height_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PersonalField(
                    controller: _weightController,
                    label: AppStrings.of(context).text('weight'),
                    suffix: AppStrings.of(context).text('kg'),
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.of(context).text('chooseGoals'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.of(context).text('goalHint'),
              style: const TextStyle(color: Appcolors.Grey2),
            ),
            const SizedBox(height: 8),
            ..._goals.map(
              (goal) => CheckboxListTile(
                value: _selectedGoals.contains(goal),
                activeColor: Appcolors.Primary,
                contentPadding: EdgeInsets.zero,
                title: Text(_localizedGoal(context, goal)),
                onChanged: (selected) {
                  setState(() {
                    if (selected ?? false) {
                      _selectedGoals.add(goal);
                    } else {
                      _selectedGoals.remove(goal);
                    }
                  });
                },
              ),
            ),
          ],
        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
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
                  child: Text(
                    AppStrings.of(context).text('saveChanges'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  const _GenderChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onSelected(),
    selectedColor: Appcolors.Primary,
    backgroundColor: Appcolors.White,
    side: BorderSide(
      color: selected ? Appcolors.Primary : Appcolors.Grey3,
    ),
    labelStyle: TextStyle(
      color: selected ? Appcolors.White : Appcolors.Black,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _PersonalField extends StatelessWidget {
  const _PersonalField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    this.decimal = true,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final bool decimal;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: decimal),
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixIcon: Icon(icon, color: Appcolors.Primary),
      filled: true,
      fillColor: Appcolors.White,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Appcolors.Grey3),
      ),
    ),
  );
}

String _localizedGoal(BuildContext context, String goal) {
  final strings = AppStrings.of(context);
  return switch (goal) {
    'Build healthy habits' => strings.text('goalBuildHabits'),
    'Improve sleep' => strings.text('goalImproveSleep'),
    'Stay active' => strings.text('goalStayActive'),
    'Eat healthier' => strings.text('goalEatHealthier'),
    'Manage medications' => strings.text('goalManageMedications'),
    _ => goal,
  };
}

String _focusMessage(BuildContext context, String goal) {
  final strings = AppStrings.of(context);
  return switch (goal) {
    'Manage medications' => strings.text('focusMedication'),
    'Improve sleep' => strings.text('focusSleep'),
    'Stay active' => strings.text('focusActivity'),
    'Eat healthier' => strings.text('focusNutrition'),
    _ => strings.text('focusHabits'),
  };
}
