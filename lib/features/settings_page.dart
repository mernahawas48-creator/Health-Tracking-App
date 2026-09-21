import 'package:flutter/material.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/appcolors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final AppSettingsController controller;

  Future<void> _openGoals(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => _GoalsPage(controller: controller)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final s = AppStrings.of(context);
        return Scaffold(
          backgroundColor: const Color(0xffF9F7FB),
          appBar: AppBar(
            backgroundColor: Appcolors.White,
            foregroundColor: Appcolors.Black,
            elevation: 0,
            centerTitle: true,
            title: Text(
              s.text('settings'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                s.text('goals'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _SettingsRow(
                    icon: Icons.flag_outlined,
                    title: s.text('dailyGoals'),
                    subtitle:
                        '${settings.waterGoalMl} ml ${s.text('water').toLowerCase()} • ${settings.sleepGoalMinutes ~/ 60} ${s.text('hours')} ${s.text('sleep').toLowerCase()}',
                    onTap: () => _openGoals(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Daily reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                SwitchListTile(
                  secondary: const Icon(Icons.water_drop_outlined, color: Appcolors.Primary),
                  title: const Text('Water reminder'),
                  subtitle: Text('${settings.waterReminderHour.toString().padLeft(2, '0')}:00 daily'),
                  value: settings.waterReminderEnabled,
                  activeThumbColor: Appcolors.Primary,
                  onChanged: (value) => controller.update(settings.copyWith(waterReminderEnabled: value)),
                ),
                const Divider(height: 1, indent: 68),
                SwitchListTile(
                  secondary: const Icon(Icons.bedtime_outlined, color: Appcolors.Primary),
                  title: const Text('Sleep reminder'),
                  subtitle: Text('${settings.sleepReminderHour.toString().padLeft(2, '0')}:00 daily'),
                  value: settings.sleepReminderEnabled,
                  activeThumbColor: Appcolors.Primary,
                  onChanged: (value) => controller.update(settings.copyWith(sleepReminderEnabled: value)),
                ),
              ]),
              const SizedBox(height: 24),
              Text(
                s.text('appearanceLanguage'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _ChoiceRow<AppThemePreference>(
                    icon: Icons.dark_mode_outlined,
                    title: s.text('theme'),
                    value: settings.theme,
                    label: _themeLabel(settings.theme, s),
                    values: AppThemePreference.values,
                    itemLabel: (value) => _themeLabel(value, s),
                    onChanged: (value) =>
                        controller.update(settings.copyWith(theme: value)),
                  ),
                  const Divider(height: 1, indent: 68),
                  _ChoiceRow<String>(
                    icon: Icons.language_rounded,
                    title: s.text('language'),
                    value: settings.languageCode,
                    label: settings.isArabic
                        ? s.text('arabic')
                        : s.text('english'),
                    values: const ['en', 'ar'],
                    itemLabel: (value) =>
                        value == 'ar' ? s.text('arabic') : s.text('english'),
                    onChanged: (value) => controller.update(
                      settings.copyWith(languageCode: value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                s.text('units'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _SettingsCard(
                children: [
                  _ChoiceRow<MeasurementUnit>(
                    icon: Icons.straighten_rounded,
                    title: s.text('measurementUnits'),
                    value: settings.unit,
                    label: settings.unit == MeasurementUnit.metric
                        ? s.text('metric')
                        : s.text('imperial'),
                    values: MeasurementUnit.values,
                    itemLabel: (value) => value == MeasurementUnit.metric
                        ? s.text('metric')
                        : s.text('imperial'),
                    onChanged: (value) =>
                        controller.update(settings.copyWith(unit: value)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                s.text('savedDevice'),
                style: TextStyle(
                  color: Appcolors.Grey2,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _themeLabel(AppThemePreference value, AppStrings strings) {
    switch (value) {
      case AppThemePreference.system:
        return strings.text('systemDefault');
      case AppThemePreference.light:
        return strings.text('light');
      case AppThemePreference.dark:
        return strings.text('dark');
    }
  }
}

class _GoalsPage extends StatefulWidget {
  const _GoalsPage({required this.controller});
  final AppSettingsController controller;

  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage> {
  late final TextEditingController _waterController;
  late final TextEditingController _sleepController;
  late final TextEditingController _activityController;
  late final TextEditingController _nutritionController;

  @override
  void initState() {
    super.initState();
    final settings = widget.controller.settings;
    _waterController = TextEditingController(
      text: settings.waterGoalMl.toString(),
    );
    _sleepController = TextEditingController(
      text: (settings.sleepGoalMinutes / 60).toStringAsFixed(1),
    );
    _activityController = TextEditingController(
      text: settings.activeCaloriesGoal.toString(),
    );
    _nutritionController = TextEditingController(
      text: settings.dailyCalorieGoal.toString(),
    );
  }

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _activityController.dispose();
    _nutritionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final water = int.tryParse(_waterController.text.trim());
    final sleepHours = double.tryParse(_sleepController.text.trim());
    final activity = int.tryParse(_activityController.text.trim());
    final nutrition = int.tryParse(_nutritionController.text.trim());

    if (water == null ||
        water < 500 ||
        water > 6000 ||
        sleepHours == null ||
        sleepHours < 3 ||
        sleepHours > 14 ||
        activity == null ||
        activity < 0 ||
        activity > 3000 ||
        nutrition == null ||
        nutrition < 800 ||
        nutrition > 6000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).text('invalidGoals')),
        ),
      );
      return;
    }

    await widget.controller.update(
      widget.controller.settings.copyWith(
        waterGoalMl: water,
        sleepGoalMinutes: (sleepHours * 60).round(),
        activeCaloriesGoal: activity,
        dailyCalorieGoal: nutrition,
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        title: Text(
          s.text('dailyGoalsTitle'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _GoalField(
              controller: _waterController,
              label: s.text('waterGoal'),
              suffix: 'ml',
              icon: Icons.water_drop_outlined,
            ),
            const SizedBox(height: 14),
            _GoalField(
              controller: _sleepController,
              label: s.text('sleepGoal'),
              suffix: s.text('hours'),
              icon: Icons.bedtime_outlined,
              decimal: true,
            ),
            const SizedBox(height: 14),
            _GoalField(
              controller: _activityController,
              label: s.text('activeCaloriesGoal'),
              suffix: 'kcal',
              icon: Icons.local_fire_department_outlined,
            ),
            const SizedBox(height: 14),
            _GoalField(
              controller: _nutritionController,
              label: s.text('dailyFoodGoal'),
              suffix: 'kcal',
              icon: Icons.restaurant_outlined,
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
                ),
                child: Text(
                  s.text('saveGoals'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  const _GoalField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    this.decimal = false,
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Appcolors.White,
      border: Border.all(color: Appcolors.Grey3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Icon(icon, color: Appcolors.Primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(color: Appcolors.Grey2)),
    trailing: const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
  );
}

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.label,
    required this.values,
    required this.itemLabel,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final T value;
  final String label;
  final List<T> values;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Appcolors.Primary),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(label, style: const TextStyle(color: Appcolors.Grey2)),
    trailing: DropdownButton<T>(
      value: value,
      underline: const SizedBox(),
      items: values
          .map(
            (item) =>
                DropdownMenuItem(value: item, child: Text(itemLabel(item))),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    ),
  );
}
