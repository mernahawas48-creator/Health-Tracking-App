import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/water_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';
import 'package:meditrack/themes/appcolors.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({
    super.key,
    required this.medications,
    required this.settings,
  });
  final List<Medication> medications;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appCanvas,
    appBar: AppBar(
      backgroundColor: context.appSurface,
      foregroundColor: context.appText,
      title: Text(
        settings.isArabic ? 'التقرير الأسبوعي' : 'Weekly report',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    body: FutureBuilder<_ReportData>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              settings.isArabic ? 'آخر 7 أيام' : 'Your last 7 days',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            _ReportCard(
              icon: Icons.water_drop_outlined,
              color: Colors.blue,
              title: settings.isArabic ? 'الماء' : 'Water',
              value: '${data.weekWaterMl} ml',
              detail: settings.isArabic
                  ? 'إجمالي آخر 7 أيام • سلسلة ${data.waterStreak} يوم'
                  : 'Last 7 days • ${data.waterStreak} day streak',
            ),
            _ReportCard(
              icon: Icons.bedtime_outlined,
              color: Colors.indigo,
              title: settings.isArabic ? 'النوم' : 'Sleep',
              value: '${data.weekSleepMinutes ~/ 60} h',
              detail: settings.isArabic
                  ? 'إجمالي آخر 7 أيام • سلسلة ${data.sleepStreak} يوم'
                  : 'Last 7 days • ${data.sleepStreak} day streak',
            ),
            _ReportCard(
              icon: Icons.medication_outlined,
              color: Appcolors.Primary,
              title: settings.isArabic ? 'الأدوية' : 'Medication',
              value: '${data.medicationRate}%',
              detail: settings.isArabic
                  ? 'اليوم: ${data.taken}/${data.scheduled} جرعات تم أخذها.'
                  : 'Today: ${data.taken}/${data.scheduled} doses taken.',
            ),
            _ReportCard(
              icon: Icons.restaurant_outlined,
              color: Colors.orange,
              title: settings.isArabic ? 'التغذية' : 'Nutrition',
              value: '${data.weekCalories} kcal',
              detail: settings.isArabic
                  ? 'تم تسجيلها خلال آخر 7 أيام. الهدف اليومي: ${settings.dailyCalorieGoal} kcal.'
                  : 'Logged over the past 7 days. Daily goal: ${settings.dailyCalorieGoal} kcal.',
            ),
          ],
        );
      },
    ),
  );

  Future<_ReportData> _load() async {
    final water = await HabitStreakService.currentStreak(HabitType.water);
    final sleep = await HabitStreakService.currentStreak(HabitType.sleep);
    final localMedications = medications.isEmpty
        ? await MedicationRepository().load()
        : medications;
    var scheduled = 0;
    var taken = 0;
    var calories = 0.0;
    var waterMl = 0;
    var sleepMinutes = 0;
    final waterRepository = WaterRepository();
    final sleepRepository = SleepRepository();
    for (var daysAgo = 0; daysAgo < 7; daysAgo++) {
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final logs = await NutritionRepository().loadForDate(date);
      calories += logs.fold(0, (sum, log) => sum + log.calories);
      waterMl += await waterRepository.loadForDate(date);
      sleepMinutes += await sleepRepository.loadForDate(date);
      final adherence = MedicationAdherenceService.summaryForDate(
        localMedications,
        date,
      );
      scheduled += adherence.scheduledCount;
      taken += adherence.takenCount;
    }
    return _ReportData(
      water,
      sleep,
      scheduled,
      taken,
      scheduled == 0 ? 0 : ((taken / scheduled) * 100).round(),
      calories.round(),
      waterMl,
      sleepMinutes,
    );
  }
}

class _ReportData {
  const _ReportData(
    this.waterStreak,
    this.sleepStreak,
    this.scheduled,
    this.taken,
    this.medicationRate,
    this.weekCalories,
    this.weekWaterMl,
    this.weekSleepMinutes,
  );
  final int waterStreak,
      sleepStreak,
      scheduled,
      taken,
      medicationRate,
      weekCalories,
      weekWaterMl,
      weekSleepMinutes;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.detail,
  });
  final IconData icon;
  final Color color;
  final String title, value, detail;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(detail),
      trailing: Text(
        value,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
