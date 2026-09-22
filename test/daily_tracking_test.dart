import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';
import 'package:meditrack/services/water_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

String dayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('water and sleep start a new day without losing yesterday', () async {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final water = WaterRepository();
    final sleep = SleepRepository();
    await water.saveForDate(yesterday, 1800);
    await sleep.saveForDate(yesterday, 450);
    expect(await water.loadToday(), 0);
    expect(await sleep.loadToday(), 0);
    await water.saveToday(250);
    await sleep.saveToday(480);
    expect(await water.loadForDate(yesterday), 1800);
    expect(await sleep.loadForDate(yesterday), 450);
    expect(await water.loadToday(), 250);
    expect(await sleep.loadToday(), 480);
  });

  test('sleep schedule fields survive a repository restart', () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await SleepRepository().saveRecordForDate(
      yesterday,
      const SleepRecord(
        durationMinutes: 450,
        bedtimeMinutes: 23 * 60,
        wakeUpMinutes: 6 * 60 + 30,
      ),
    );
    final restored = await SleepRepository().loadRecordForDate(yesterday);
    expect(restored.durationMinutes, 450);
    expect(restored.bedtimeMinutes, 23 * 60);
    expect(restored.wakeUpMinutes, 6 * 60 + 30);
  });

  test('legacy water and sleep records remain readable', () async {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final oldKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    SharedPreferences.setMockInitialValues({
      'water_today_v1': jsonEncode({'date': oldKey, 'waterMl': 1800}),
      'sleep_today_v1': jsonEncode({'date': oldKey, 'sleepMinutes': 450}),
    });
    expect(await WaterRepository().loadToday(), 0);
    expect(await SleepRepository().loadToday(), 0);
    expect(await WaterRepository().loadForDate(yesterday), 1800);
    expect(await SleepRepository().loadForDate(yesterday), 450);
    await WaterRepository().saveToday(100);
    expect(await WaterRepository().loadForDate(yesterday), 1800);
  });

  test('nutrition keeps yesterday when today is saved', () async {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    FoodLog log(String id, DateTime date) => FoodLog(
      id: id,
      food: const NutritionFood(
        fdcId: 1,
        name: 'Food',
        caloriesPer100g: 100,
        proteinPer100g: 10,
        carbsPer100g: 20,
        fatPer100g: 5,
      ),
      amountGrams: 100,
      mealType: MealType.breakfast,
      loggedAt: date,
    );
    final oldLog = log('old', yesterday);
    SharedPreferences.setMockInitialValues({
      'nutrition_logs_v1': [jsonEncode(oldLog.toJson())],
    });
    final repository = NutritionRepository();
    expect(await repository.loadToday(), isEmpty);
    await repository.saveToday([log('new', today)]);
    expect((await repository.loadForDate(yesterday)).single.id, 'old');
    expect((await repository.loadToday()).single.id, 'new');
  });

  test('streak counts consecutive dates once and keeps yesterday', () async {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final twoDaysAgo = DateTime(today.year, today.month, today.day - 2);
    SharedPreferences.setMockInitialValues({
      'water_completed_dates': [
        dayKey(yesterday),
        dayKey(yesterday),
        dayKey(twoDaysAgo),
      ],
    });
    expect(await HabitStreakService.currentStreak(HabitType.water), 2);
    await HabitStreakService.updateToday(
      habit: HabitType.water,
      isCompleted: true,
    );
    expect(await HabitStreakService.currentStreak(HabitType.water), 3);
    await HabitStreakService.updateToday(
      habit: HabitType.water,
      isCompleted: false,
    );
    expect(await HabitStreakService.currentStreak(HabitType.water), 2);
  });

  test('medication adherence is separate for each scheduled date', () {
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final medication = Medication(
      id: 'daily',
      name: 'Tablet',
      type: MedicationType.tablet,
      dosage: '1',
      frequency: MedicationFrequency.daily,
      startDate: yesterday,
      time: const TimeOfDay(hour: 8, minute: 0),
      mealRelation: MealRelation.anyTime,
    ).withStatus(yesterday, DoseStatus.taken);
    expect(
      MedicationAdherenceService.summaryForDate([
        medication,
      ], yesterday).takenCount,
      1,
    );
    expect(
      MedicationAdherenceService.summaryForDate([
        medication,
      ], today).pendingCount,
      1,
    );
    expect(MedicationAdherenceService.currentStreak([medication]), 1);
  });
}
