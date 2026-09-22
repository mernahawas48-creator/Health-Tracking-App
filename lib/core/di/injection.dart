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
import 'package:meditrack/services/account_firestore.dart';
import 'package:meditrack/services/user_profile_repository.dart';
import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/services/health_assistant_service.dart';
import 'package:meditrack/services/notification_state_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
  }
  if (!getIt.isRegistered<AccountFirestore>()) {
    getIt.registerLazySingleton<AccountFirestore>(() => AccountFirestore());
  }
  if (!getIt.isRegistered<UserProfileRepository>()) {
    getIt.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepository(getIt()),
    );
  }
  if (!getIt.isRegistered<NotificationStateRepository>()) {
    getIt.registerLazySingleton<NotificationStateRepository>(
      () => NotificationStateRepository(getIt()),
    );
  }
  if (!getIt.isRegistered<HealthAssistantService>()) {
    getIt.registerLazySingleton<HealthAssistantService>(
      () => FirebaseHealthAssistantService(),
    );
  }
  if (!getIt.isRegistered<LocalSessionService>()) {
    getIt.registerLazySingleton<LocalSessionService>(
      () => LocalSessionService(),
    );
  }
  if (!getIt.isRegistered<MedicationRepository>()) {
    getIt.registerLazySingleton<MedicationRepository>(
      () => FirestoreMedicationRepository(getIt()),
    );
  }
  if (!getIt.isRegistered<MedicationNotificationService>()) {
    getIt.registerLazySingleton<MedicationNotificationService>(
      () => MedicationNotificationService.instance,
    );
  }
  if (!getIt.isRegistered<NutritionRepository>()) {
    getIt.registerLazySingleton<NutritionRepository>(
      () => FirestoreNutritionRepository(getIt()),
    );
  }
  if (!getIt.isRegistered<UsdaFoodService>()) {
    getIt.registerLazySingleton<UsdaFoodService>(() => UsdaFoodService());
  }
  if (!getIt.isRegistered<WaterRepository>()) {
    getIt.registerLazySingleton<WaterRepository>(
      () => FirestoreWaterRepository(getIt()),
    );
  }
  if (!getIt.isRegistered<SleepRepository>()) {
    getIt.registerLazySingleton<SleepRepository>(
      () => FirestoreSleepRepository(getIt()),
    );
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
