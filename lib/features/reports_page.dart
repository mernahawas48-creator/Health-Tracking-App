import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/themes/appcolors.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.medications, required this.settings});
  final List<Medication> medications;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xffF9F7FB),
    appBar: AppBar(backgroundColor: Appcolors.White, foregroundColor: Appcolors.Black, title: const Text('Weekly report', style: TextStyle(fontWeight: FontWeight.bold))),
    body: FutureBuilder<_ReportData>(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Your last 7 days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 12),
          _ReportCard(icon: Icons.water_drop_outlined, color: Colors.blue, title: 'Water', value: '${data.waterStreak} day streak', detail: 'Keep meeting your ${settings.waterGoalMl} ml goal.'),
          _ReportCard(icon: Icons.bedtime_outlined, color: Colors.indigo, title: 'Sleep', value: '${data.sleepStreak} day streak', detail: 'Goal: ${settings.sleepGoalMinutes ~/ 60} hours each night.'),
          _ReportCard(icon: Icons.medication_outlined, color: Appcolors.Primary, title: 'Medication', value: '${data.medicationRate}%', detail: 'Today: ${data.taken}/${data.scheduled} doses taken.'),
          _ReportCard(icon: Icons.restaurant_outlined, color: Colors.orange, title: 'Nutrition', value: '${data.weekCalories} kcal', detail: 'Logged over the past 7 days. Daily goal: ${settings.dailyCalorieGoal} kcal.'),
        ]);
      },
    ),
  );

  Future<_ReportData> _load() async {
    final water = await HabitStreakService.currentStreak(HabitType.water);
    final sleep = await HabitStreakService.currentStreak(HabitType.sleep);
    final localMedications = medications.isEmpty
        ? await MedicationRepository().load()
        : medications;
    final med = MedicationAdherenceService.summaryForToday(localMedications);
    var calories = 0.0;
    for (var daysAgo = 0; daysAgo < 7; daysAgo++) {
      final logs = await NutritionRepository().loadForDate(DateTime.now().subtract(Duration(days: daysAgo)));
      calories += logs.fold(0, (sum, log) => sum + log.calories);
    }
    return _ReportData(water, sleep, med.scheduledCount, med.takenCount, med.scheduledCount == 0 ? 0 : (med.completionRate * 100).round(), calories.round());
  }
}

class _ReportData { const _ReportData(this.waterStreak, this.sleepStreak, this.scheduled, this.taken, this.medicationRate, this.weekCalories); final int waterStreak, sleepStreak, scheduled, taken, medicationRate, weekCalories; }
class _ReportCard extends StatelessWidget { const _ReportCard({required this.icon, required this.color, required this.title, required this.value, required this.detail}); final IconData icon; final Color color; final String title, value, detail; @override Widget build(BuildContext context) => Card(child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(detail), trailing: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)))); }
