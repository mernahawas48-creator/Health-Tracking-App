import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/account_firestore.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';
import 'package:meditrack/services/user_profile_repository.dart';
import 'package:meditrack/services/water_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A and B have separate Firestore profile and health records', () async {
    final firestore = FakeFirebaseFirestore();
    String? uid = 'A';
    final account = AccountFirestore(
      firestore: firestore,
      uidProvider: () => uid,
    );
    final profiles = UserProfileRepository(account);
    final meds = FirestoreMedicationRepository(account);
    final nutrition = FirestoreNutritionRepository(account);
    final water = FirestoreWaterRepository(account);
    final sleep = FirestoreSleepRepository(account);
    final today = DateTime(2026, 9, 22);
    final yesterday = DateTime(2026, 9, 21);
    final medication = Medication(
      id: 'med-1',
      name: 'A medicine',
      type: MedicationType.tablet,
      dosage: '1',
      frequency: MedicationFrequency.daily,
      startDate: today,
      time: const TimeOfDay(hour: 8, minute: 0),
      mealRelation: MealRelation.anyTime,
      doseStatuses: {'2026-09-21': DoseStatus.taken},
    );
    final log = FoodLog(
      id: 'food-1',
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
      loggedAt: today,
    );
    await profiles.save('A', {
      'displayName': 'Alice',
      'profileSetupComplete': true,
      'healthGoals': ['Walk'],
    });
    await meds.save([medication]);
    await nutrition.saveToday([log]);
    await water.saveForDate(yesterday, 1800);
    await water.saveForDate(today, 2300);
    await sleep.saveForDate(today, 480);
    expect(await water.loadForDate(yesterday), 1800);
    expect(await water.loadForDate(today), 2300);
    expect(
      (await meds.load()).single.doseStatuses['2026-09-21'],
      DoseStatus.taken,
    );

    uid = 'B';
    expect(await profiles.load('B'), isNull);
    expect(await meds.load(), isEmpty);
    expect(await nutrition.loadForDate(today), isEmpty);
    expect(await water.loadForDate(today), 0);
    expect(await sleep.loadForDate(today), 0);
    expect(() => profiles.load('A'), throwsStateError);
    await profiles.save('B', {
      'displayName': 'Bob',
      'profileSetupComplete': true,
      'healthGoals': <String>[],
    });
    await water.saveForDate(today, 900);

    uid = 'A';
    expect((await profiles.load('A'))?['displayName'], 'Alice');
    expect((await meds.load()).single.name, 'A medicine');
    expect((await nutrition.loadForDate(today)).single.food.name, 'Food');
    expect(await water.loadForDate(today), 2300);
    expect(await sleep.loadForDate(today), 480);
    uid = 'B';
    expect(await water.loadForDate(today), 900);
    expect((await profiles.load('B'))?['displayName'], 'Bob');
  });

  test('streak completion is stored under the current UID', () async {
    final firestore = FakeFirebaseFirestore();
    String? uid = 'A';
    HabitStreakService.account = AccountFirestore(
      firestore: firestore,
      uidProvider: () => uid,
    );
    addTearDown(() => HabitStreakService.account = null);
    await HabitStreakService.updateToday(
      habit: HabitType.water,
      isCompleted: true,
    );
    expect(await HabitStreakService.currentStreak(HabitType.water), 1);
    uid = 'B';
    expect(await HabitStreakService.currentStreak(HabitType.water), 0);
    uid = 'A';
    expect(await HabitStreakService.currentStreak(HabitType.water), 1);
  });
}
