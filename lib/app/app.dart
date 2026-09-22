import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/features/medications/medication_cubit.dart';
import 'package:meditrack/features/nutrition/nutrition_cubit.dart';
import 'package:meditrack/features/water/water_cubit.dart';
import 'package:meditrack/features/sleep/sleep_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meditrack/models/app_settings.dart';
import 'package:meditrack/services/app_settings_controller.dart';
import 'package:meditrack/themes/app_theme.dart';

import 'routes.dart';

class HealthApp extends StatelessWidget {
  const HealthApp({super.key, required this.settingsController});

  final AppSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SessionCubit(
            getIt(),
            signOutExistingAuth: () => AuthService().logout(),
          )..restore(),
        ),
        BlocProvider(create: (_) => getIt<MedicationCubit>()..load()),
        BlocProvider(create: (_) => getIt<NutritionCubit>()..load()),
        BlocProvider(create: (_) => getIt<WaterCubit>()..load()),
        BlocProvider(create: (_) => getIt<SleepCubit>()..load()),
      ],
      child: AppSettingsScope(
        controller: settingsController,
        child: AnimatedBuilder(
          animation: settingsController,
          builder: (context, _) {
            final settings = settingsController.settings;

            return BlocBuilder<SessionCubit, SessionStatus>(
              builder: (context, _) {
                final uid = context.read<SessionCubit>().activeUid;
                return MultiBlocProvider(
                  key: ValueKey(uid),
                  providers: [
                    BlocProvider(
                      create: (_) {
                        final cubit = getIt<MedicationCubit>();
                        if (uid != null) cubit.load();
                        return cubit;
                      },
                    ),
                    BlocProvider(
                      create: (_) {
                        final cubit = getIt<NutritionCubit>();
                        if (uid != null) cubit.load();
                        return cubit;
                      },
                    ),
                    BlocProvider(
                      create: (_) {
                        final cubit = getIt<WaterCubit>();
                        if (uid != null) cubit.load();
                        return cubit;
                      },
                    ),
                    BlocProvider(
                      create: (_) {
                        final cubit = getIt<SleepCubit>();
                        if (uid != null) cubit.load();
                        return cubit;
                      },
                    ),
                  ],
                  child: MaterialApp(
                    key: ValueKey(uid),
                    debugShowCheckedModeBanner: false,
                    title: settings.isArabic
                        ? 'متابعة الصحة'
                        : 'Health Tracker',
                    locale: Locale(settings.languageCode),
                    supportedLocales: const [Locale('en'), Locale('ar')],
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    themeMode: _themeMode(settings.theme),
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    initialRoute: '/',
                    routes: appRoutes,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  ThemeMode _themeMode(AppThemePreference value) {
    switch (value) {
      case AppThemePreference.system:
        return ThemeMode.system;
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}
