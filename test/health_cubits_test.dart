import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/medications/medication_cubit.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/features/nutrition/nutrition_cubit.dart';
import 'package:meditrack/features/sleep/sleep_cubit.dart';
import 'package:meditrack/features/water/water_cubit.dart';
import 'package:meditrack/models/nutrition_food.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';
import 'package:meditrack/services/usda_food_service.dart';
import 'package:meditrack/services/water_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('medication changes persist and adherence updates', () async {
    final cubit = MedicationCubit(
      MedicationRepository(),
      MedicationNotificationService.instance,
    );
    await cubit.load();
    final medication = Medication(
      id: 'med-1',
      name: 'Tablet',
      type: MedicationType.tablet,
      dosage: '1',
      frequency: MedicationFrequency.asNeeded,
      startDate: DateTime.now(),
      time: const TimeOfDay(hour: 8, minute: 0),
      mealRelation: MealRelation.anyTime,
    );
    await cubit.add(medication);
    expect(cubit.state.medications.length, 1);
    expect((await MedicationRepository().load()).length, 1);
    await cubit.update(
      Medication(
        id: medication.id,
        name: 'Updated',
        type: medication.type,
        dosage: medication.dosage,
        frequency: medication.frequency,
        startDate: medication.startDate,
        time: medication.time,
        mealRelation: medication.mealRelation,
      ),
    );
    expect(cubit.state.medications.single.name, 'Updated');
    await cubit.delete(cubit.state.medications.single);
    expect(await MedicationRepository().load(), isEmpty);
    await cubit.close();
  });

  test('nutrition logs and totals persist', () async {
    final cubit = NutritionCubit(NutritionRepository(), UsdaFoodService());
    await cubit.load();
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
      amountGrams: 150,
      mealType: MealType.breakfast,
      loggedAt: DateTime.now(),
    );
    await cubit.add(log);
    expect(cubit.state.calories, 150);
    expect(cubit.state.protein, 15);
    expect((await NutritionRepository().loadToday()).length, 1);
    await cubit.remove(log);
    expect(await NutritionRepository().loadToday(), isEmpty);
    await cubit.close();
  });

  test('water and sleep persist progress and streaks', () async {
    final water = WaterCubit(WaterRepository());
    final sleep = SleepCubit(SleepRepository());
    await water.load();
    await sleep.load();
    water.beginEdit();
    water.add(150);
    water.add(150);
    expect(water.state.displayedMl, 300);
    expect(await WaterRepository().loadToday(), 0);
    expect(await water.save(300), isTrue);
    expect(water.state.intakeMl, 300);
    expect(water.state.progress(300), 1);
    expect(await WaterRepository().loadToday(), 300);
    await sleep.save(480);
    expect(sleep.state.progress(480), 1);
    expect(await SleepRepository().loadToday(), 480);
    water.beginEdit();
    water.reset();
    expect(water.state.displayedMl, 0);
    water.discard();
    expect(water.state.intakeMl, 300);
    await water.close();
    await sleep.close();
  });
}
