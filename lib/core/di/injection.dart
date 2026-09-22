import 'package:get_it/get_it.dart';
import 'package:meditrack/services/local_session_service.dart';
import 'package:meditrack/features/medications/medication_cubit.dart';
import 'package:meditrack/features/nutrition/nutrition_cubit.dart';
import 'package:meditrack/features/water/water_cubit.dart';
import 'package:meditrack/features/sleep/sleep_cubit.dart';
import 'package:meditrack/services/medication_repository.dart';
import 'package:meditrack/services/medication_notification_service.dart';
import 'package:meditrack/services/nutrition_repository.dart';
import 'package:meditrack/services/usda_food_service.dart';
import 'package:meditrack/services/water_repository.dart';
import 'package:meditrack/services/sleep_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (!getIt.isRegistered<LocalSessionService>()) {
    getIt.registerLazySingleton<LocalSessionService>(
      () => LocalSessionService(),
    );
  }
  if (!getIt.isRegistered<MedicationRepository>()) {
    getIt.registerLazySingleton<MedicationRepository>(
      () => MedicationRepository(),
    );
  }
  if (!getIt.isRegistered<MedicationNotificationService>()) {
    getIt.registerLazySingleton<MedicationNotificationService>(
      () => MedicationNotificationService.instance,
    );
  }
  if (!getIt.isRegistered<NutritionRepository>()) {
    getIt.registerLazySingleton<NutritionRepository>(
      () => NutritionRepository(),
    );
  }
  if (!getIt.isRegistered<UsdaFoodService>()) {
    getIt.registerLazySingleton<UsdaFoodService>(() => UsdaFoodService());
  }
  if (!getIt.isRegistered<WaterRepository>()) {
    getIt.registerLazySingleton<WaterRepository>(() => WaterRepository());
  }
  if (!getIt.isRegistered<SleepRepository>()) {
    getIt.registerLazySingleton<SleepRepository>(() => SleepRepository());
  }
  if (!getIt.isRegistered<MedicationCubit>()) {
    getIt.registerFactory<MedicationCubit>(
      () => MedicationCubit(getIt(), getIt()),
    );
  }
  if (!getIt.isRegistered<NutritionCubit>()) {
    getIt.registerFactory<NutritionCubit>(
      () => NutritionCubit(getIt(), getIt()),
    );
  }
  if (!getIt.isRegistered<WaterCubit>()) {
    getIt.registerFactory<WaterCubit>(() => WaterCubit(getIt()));
  }
  if (!getIt.isRegistered<SleepCubit>()) {
    getIt.registerFactory<SleepCubit>(() => SleepCubit(getIt()));
  }
}
