import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/add_medication_page.dart';
import 'package:meditrack/features/medications/medications_page.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/features/water_tracker_page.dart';
import 'package:meditrack/features/sleep_tracker_page.dart';
import 'package:meditrack/features/nutrition_page.dart';
import 'package:meditrack/features/profile_page.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/features/ai_assistant_page.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';
import 'package:meditrack/services/water_repository.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Medication> _medications = [];
  final MedicationRepository _medicationRepository = MedicationRepository();
  final NutritionRepository _nutritionRepository = NutritionRepository();
  final SleepRepository _sleepRepository = SleepRepository();
  final WaterRepository _waterRepository = WaterRepository();
  bool _isLoadingDashboard = true;
  final List<FoodLog> _foodLogs = [];
  int _waterMl = 0;
  int _waterStreak = 0;
  int _sleepMinutes = 0;
  int _sleepStreak = 0;
  String _userName = 'User Name';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final medications = await _medicationRepository.load();
    final waterMl = await _waterRepository.loadToday();
    final sleepMinutes = await _sleepRepository.loadToday();
    final foodLogs = await _nutritionRepository.loadToday();
    final waterStreak = await HabitStreakService.currentStreak(HabitType.water);
    final sleepStreak = await HabitStreakService.currentStreak(HabitType.sleep);
    if (!mounted) return;
    setState(() {
      _medications
        ..clear()
        ..addAll(medications);
      _foodLogs
        ..clear()
        ..addAll(foodLogs);
      _waterMl = waterMl;
      _sleepMinutes = sleepMinutes;
      _waterStreak = waterStreak;
      _sleepStreak = sleepStreak;
      _isLoadingDashboard = false;
    });
  }

  Future<void> _saveMedications() async {
    await _medicationRepository.save(_medications);
    for (final medication in _medications) {
      try {
        await MedicationNotificationService.instance.sync(medication);
      } catch (_) {
        // The medication is already saved; Android alerts can be retried later.
      }
    }
  }

  Future<void> _loadStreaks() async {
    final waterStreak = await HabitStreakService.currentStreak(HabitType.water);
    final sleepStreak = await HabitStreakService.currentStreak(HabitType.sleep);
    if (mounted) {
      setState(() {
        _waterStreak = waterStreak;
        _sleepStreak = sleepStreak;
      });
    }
  }

  List<Medication> get _today {
    final now = DateTime.now();
    final items = _medications
        .where((item) => item.isScheduledFor(now))
        .toList();
    items.sort((a, b) => a.nextDoseAfter(now).compareTo(b.nextDoseAfter(now)));
    return items;
  }

  Medication? get _upcoming {
    final now = DateTime.now();
    final items = _medications
        .where((item) => item.hasScheduledReminder)
        .toList();
    if (items.isEmpty) return null;
    items.sort((a, b) => a.nextDoseAfter(now).compareTo(b.nextDoseAfter(now)));
    return items.first;
  }

  Future<void> _addMedication() async {
    final medication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationPage()),
    );
    if (medication == null || !mounted) return;
    setState(() => _medications.add(medication));
    await _saveMedications();
  }

  Future<void> _addMedicationFromList(Medication medication) async {
    setState(() => _medications.add(medication));
    await _saveMedications();
  }

  Future<void> _updateMedication(Medication updatedMedication) async {
    final index = _medications.indexWhere(
      (item) => item.id == updatedMedication.id,
    );
    if (index < 0) return;
    setState(() => _medications[index] = updatedMedication);
    await _saveMedications();
  }

  Future<void> _deleteMedication(Medication medication) async {
    setState(() => _medications.removeWhere((item) => item.id == medication.id));
    await MedicationNotificationService.instance.cancel(medication);
    await _saveMedications();
  }

  Future<void> _openMedications() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicationsPage(
          medications: _medications,
          onMedicationAdded: _addMedicationFromList,
          onMedicationChanged: _updateMedication,
          onMedicationDeleted: _deleteMedication,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openNutrition() async {
    final settings = AppSettingsScope.of(context).settings;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionPage(
          foodLogs: _foodLogs,
          calorieGoal: settings.dailyCalorieGoal,
          onLogsChanged: _nutritionRepository.saveToday,
        ),
      ),
    );
    await _loadDashboardData();
  }

  Future<void> _openProfile() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          initialName: _userName,
          onNameChanged: (name) {
            if (mounted) setState(() => _userName = name);
          },
        ),
      ),
    );
  }

  Future<void> _openWaterTracker() async {
    final settings = AppSettingsScope.of(context).settings;
    final waterMl = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            WaterTrackerPage(
              initialWaterMl: _waterMl,
              goalMl: settings.waterGoalMl,
            ),
      ),
    );
    if (waterMl != null && mounted) {
      setState(() => _waterMl = waterMl);
      await _waterRepository.saveToday(waterMl);
      _loadStreaks();
    }
  }

  Future<void> _openSleepTracker() async {
    final settings = AppSettingsScope.of(context).settings;
    final sleepMinutes = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => SleepTrackerPage(
          initialSleepMinutes: _sleepMinutes,
          goalMinutes: settings.sleepGoalMinutes,
        ),
      ),
    );
    if (sleepMinutes != null && mounted) {
      setState(() => _sleepMinutes = sleepMinutes);
      await _sleepRepository.saveToday(sleepMinutes);
      _loadStreaks();
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '$hours h';
    return '$hours h $remainingMinutes min';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final settings = AppSettingsScope.of(context).settings;
    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: _isLoadingDashboard
                ? const Padding(
                    padding: EdgeInsets.only(top: 90),
                    child: CircularProgressIndicator(color: Appcolors.Primary),
                  )
                : Column(
                    children: [
                _header(strings),
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _upcomingCard(),
                              const SizedBox(height: 20),
                              _activityCard(settings.activeCaloriesGoal),
                              const SizedBox(height: 20),
                              _waterSleep(
                                waterGoalMl: settings.waterGoalMl,
                                sleepGoalMinutes: settings.sleepGoalMinutes,
                              ),
                              const SizedBox(height: 20),
                              _nutritionSummaryCard(settings.dailyCalorieGoal),
                              const SizedBox(height: 20),
                              _todayCard(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: 'aiAssistant',
              backgroundColor: Appcolors.White,
              shape: const CircleBorder(),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantPage())),
              child: const Text('🤖', style: TextStyle(fontSize: 27)),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Appcolors.White, width: 4),
            ),
            child: FloatingActionButton(
              heroTag: 'addAlert',
              backgroundColor: Appcolors.Primary,
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: _addMedication,
              child: const Icon(Icons.add, color: Appcolors.White, size: 40),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            AppStrings.of(context).text('addAlert'),
            style: TextStyle(
              color: Appcolors.Grey2,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_outlined, strings.text('home')),
            _navItem(1, Icons.local_pharmacy_outlined, strings.text('meds')),
            const SizedBox(width: 70),
            _navItem(2, Icons.eco_outlined, strings.text('nutrition')),
            _navItem(3, Icons.person_2_outlined, strings.text('profile')),
          ],
        ),
      ),
    );
  }

  Widget _header(AppStrings strings) => Container(
    width: double.infinity,
    height: 203,
    color: Appcolors.Primary,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person)),
          const SizedBox(width: 15),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.text('welcome')} 👋',
                style: const TextStyle(
                  color: Appcolors.White,
                  fontFamily: 'Inter',
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: const TextStyle(
                  color: Appcolors.White,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (sheetContext) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.notifications_active_outlined, color: Appcolors.SecondaryOrange, size: 36),
                    const SizedBox(height: 12),
                    const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(_upcoming == null ? 'No upcoming medication reminders.' : '${_upcoming!.name} is due at ${_upcoming!.formattedTime}.'),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              icon: const Icon(
                Icons.notifications_none,
                color: Appcolors.White,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Appcolors.White,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Appcolors.Grey3),
    ),
    child: child,
  );

  Widget _upcomingCard() {
    final medication = _upcoming;
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.medication_outlined, color: Appcolors.SecondaryOrange),
              SizedBox(width: 8),
              Text(
                AppStrings.of(context).text('upcomingMedication'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (medication == null)
            Column(
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 35,
                  color: Appcolors.Grey2,
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.of(context).text('noReminders'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  AppStrings.of(context).text('addFirstMedication'),
                  style: TextStyle(color: Appcolors.Grey2),
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(medication.type.icon, size: 38, color: Appcolors.Primary),
                const SizedBox(height: 8),
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.of(context).medicationType(medication.type.name)} • ${medication.dosage}',
                  style: const TextStyle(color: Appcolors.Grey2),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppStrings.of(context).text('nextReminder')}: ${medication.formattedTime}',
                  style: const TextStyle(
                    color: Appcolors.Primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _activityCard(int activeCaloriesGoal) => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.directions_walk, color: Appcolors.Primary),
            SizedBox(width: 8),
            Text(
              AppStrings.of(context).text('activity'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.of(context).text('burnedCalories'), style: const TextStyle(fontSize: 15)),
            Text('0 / $activeCaloriesGoal kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: 0,
          minHeight: 7,
          color: Appcolors.Primary,
          backgroundColor: Color(0xffE8DFFF),
        ),
        SizedBox(height: 25),
        Row(
          children: [
            Expanded(
              child: _ActivityValue(
                icon: Icons.directions_walk,
                value: '0',
                label: AppStrings.of(context).text('steps'),
              ),
            ),
            Expanded(
              child: _ActivityValue(
                icon: Icons.route_outlined,
                value: '0.0 km',
                label: AppStrings.of(context).text('distance'),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _waterSleep({
    required int waterGoalMl,
    required int sleepGoalMinutes,
  }) => Row(
    children: [
      Expanded(
        child: _smallCard(
          icon: Icons.water_drop_outlined,
          iconColor: Colors.blue,
          title: AppStrings.of(context).text('water'),
          value: '$_waterMl / $waterGoalMl ml\n${AppStrings.of(context).dayStreak(_waterStreak)}',
          onTap: _openWaterTracker,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _smallCard(
          icon: Icons.bedtime_outlined,
          iconColor: Colors.indigo,
          title: AppStrings.of(context).text('sleep'),
          value: _sleepMinutes == 0
              ? '${AppStrings.of(context).text('noSleepLogged')}\n${AppStrings.of(context).dayStreak(_sleepStreak)}'
              : '${_formatDuration(_sleepMinutes)} / ${_formatDuration(sleepGoalMinutes)}\n${AppStrings.of(context).dayStreak(_sleepStreak)}',
          onTap: _openSleepTracker,
        ),
      ),
    ],
  );

  Widget _smallCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Appcolors.Grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Appcolors.Grey2)),
        ],
      ),
    ),
  );

  Widget _nutritionSummaryCard(int calorieGoal) {
    final consumed = _foodLogs.fold<double>(
      0,
      (total, log) => total + log.calories,
    );
    final progress = (consumed / calorieGoal).clamp(0.0, 1.0);
    return InkWell(
      onTap: _openNutrition,
      borderRadius: BorderRadius.circular(20),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_outlined, color: Appcolors.Primary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.of(context).text('nutrition'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${consumed.round()} / $calorieGoal kcal',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: Appcolors.Primary,
                backgroundColor: const Color(0xffDDF4F5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _todayCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.of(context).text('todayMedications'),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        if (_today.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 38,
                  color: Appcolors.Grey2,
                ),
                SizedBox(height: 8),
                Text(
                  AppStrings.of(context).text('noMedicationsToday'),
                  style: TextStyle(color: Appcolors.Grey2),
                ),
              ],
            ),
          )
        else
          ..._today.map(
            (medication) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffE3F7F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(medication.type.icon, color: Appcolors.Primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${AppStrings.of(context).medicationType(medication.type.name)} • ${medication.dosage}',
                          style: const TextStyle(
                            color: Appcolors.Grey2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    medication.statusOn(DateTime.now()).icon,
                    color:
                        medication.statusOn(DateTime.now()) == DoseStatus.taken
                        ? Appcolors.Primary
                        : medication.statusOn(DateTime.now()) ==
                              DoseStatus.skipped
                        ? Appcolors.SecondaryOrange
                        : Appcolors.Grey2,
                  ),
                ],
              ),
            ),
          ),
        if (_today.isNotEmpty) ...[
          const SizedBox(height: 8),
          _MedicationHomeStatus(
            summary: MedicationAdherenceService.summaryForToday(_medications),
          ),
        ],
      ],
    ),
  );

  Widget _navItem(int index, IconData icon, String title) => IconButton(
    padding: EdgeInsets.zero,
    onPressed: () async {
      if (index == 1) {
        await _openMedications();
        return;
      }
      if (index == 2) {
        await _openNutrition();
        return;
      }
      if (index == 3) {
        await _openProfile();
        return;
      }
      setState(() => selectedIndex = index);
    },
    icon: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: selectedIndex == index ? Appcolors.Primary : Appcolors.Grey2,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: selectedIndex == index ? Appcolors.Primary : Appcolors.Grey2,
          ),
        ),
      ],
    ),
  );
}

class _ActivityValue extends StatelessWidget {
  const _ActivityValue({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: Appcolors.Primary),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(label, style: const TextStyle(color: Appcolors.Grey2)),
    ],
  );
}

class _MedicationHomeStatus extends StatelessWidget {
  const _MedicationHomeStatus({required this.summary});

  final MedicationAdherenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final complete = summary.isComplete;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (complete ? Appcolors.Primary : Appcolors.SecondaryOrange)
            .withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            complete
                ? Icons.check_circle_outline_rounded
                : Icons.local_fire_department_rounded,
            color: complete ? Appcolors.Primary : Appcolors.SecondaryOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              complete
                  ? '${AppStrings.of(context).text('allDosesCompleted')} • ${AppStrings.of(context).dayStreak(summary.streakDays)}'
                  : AppStrings.of(context).medicationHomeProgress(taken: summary.takenCount, total: summary.scheduledCount, streak: summary.streakDays),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
