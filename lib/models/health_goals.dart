import 'package:flutter/widgets.dart';
import 'package:meditrack/l10n/app_strings.dart';

class HealthGoals {
  static const available = <String>[
    'Build healthy habits',
    'Improve sleep',
    'Stay active',
    'Eat healthier',
    'Manage medications',
    'Stay Healthy',
    'Lose Weight',
    'Gain Weight',
    'Build Muscle',
  ];

  static String label(BuildContext context, String goal) {
    final strings = AppStrings.of(context);
    final key = switch (goal) {
      'Build healthy habits' => 'goalBuildHabits',
      'Improve sleep' => 'goalImproveSleep',
      'Stay active' => 'goalStayActive',
      'Eat healthier' => 'goalEatHealthier',
      'Manage medications' => 'goalManageMedications',
      'Stay Healthy' => 'goalStayHealthy',
      'Lose Weight' => 'goalLoseWeight',
      'Gain Weight' => 'goalGainWeight',
      'Build Muscle' => 'goalBuildMuscle',
      _ => null,
    };
    return key == null ? goal : strings.text(key);
  }

  static String focusMessage(BuildContext context, String goal) {
    final strings = AppStrings.of(context);
    final key = switch (goal) {
      'Manage medications' => 'focusMedication',
      'Improve sleep' => 'focusSleep',
      'Stay active' || 'Build Muscle' => 'focusActivity',
      'Eat healthier' || 'Lose Weight' || 'Gain Weight' => 'focusNutrition',
      _ => 'focusHabits',
    };
    return strings.text(key);
  }
}
