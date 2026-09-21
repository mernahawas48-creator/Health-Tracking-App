enum AppThemePreference { system, light, dark }

enum MeasurementUnit { metric, imperial }

class AppSettings {
  const AppSettings({
    this.waterGoalMl = 2000,
    this.sleepGoalMinutes = 8 * 60,
    this.activeCaloriesGoal = 300,
    this.dailyCalorieGoal = 1800,
    this.unit = MeasurementUnit.metric,
    this.theme = AppThemePreference.system,
    this.languageCode = 'en',
    this.healthGoals = const [],
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.profileImagePath,
  });

  final int waterGoalMl;
  final int sleepGoalMinutes;
  final int activeCaloriesGoal;
  final int dailyCalorieGoal;
  final MeasurementUnit unit;
  final AppThemePreference theme;
  final String languageCode;
  final List<String> healthGoals;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? profileImagePath;

  bool get isArabic => languageCode == 'ar';

  AppSettings copyWith({
    int? waterGoalMl,
    int? sleepGoalMinutes,
    int? activeCaloriesGoal,
    int? dailyCalorieGoal,
    MeasurementUnit? unit,
    AppThemePreference? theme,
    String? languageCode,
    List<String>? healthGoals,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? profileImagePath,
  }) {
    return AppSettings(
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      sleepGoalMinutes: sleepGoalMinutes ?? this.sleepGoalMinutes,
      activeCaloriesGoal: activeCaloriesGoal ?? this.activeCaloriesGoal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      unit: unit ?? this.unit,
      theme: theme ?? this.theme,
      languageCode: languageCode ?? this.languageCode,
      healthGoals: healthGoals ?? this.healthGoals,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
    'waterGoalMl': waterGoalMl,
    'sleepGoalMinutes': sleepGoalMinutes,
    'activeCaloriesGoal': activeCaloriesGoal,
    'dailyCalorieGoal': dailyCalorieGoal,
    'unit': unit.name,
    'theme': theme.name,
    'languageCode': languageCode,
    'healthGoals': healthGoals,
    'age': age,
    'gender': gender,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'profileImagePath': profileImagePath,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    waterGoalMl: (json['waterGoalMl'] as num?)?.toInt() ?? 2000,
    sleepGoalMinutes: (json['sleepGoalMinutes'] as num?)?.toInt() ?? 480,
    activeCaloriesGoal: (json['activeCaloriesGoal'] as num?)?.toInt() ?? 300,
    dailyCalorieGoal: (json['dailyCalorieGoal'] as num?)?.toInt() ?? 1800,
    unit: _enumOrDefault(
      MeasurementUnit.values,
      json['unit'],
      MeasurementUnit.metric,
    ),
    theme: _enumOrDefault(
      AppThemePreference.values,
      json['theme'],
      AppThemePreference.system,
    ),
    languageCode: json['languageCode'] == 'ar' ? 'ar' : 'en',
    healthGoals: (json['healthGoals'] as List? ?? const [])
        .whereType<String>()
        .toList(),
    age: (json['age'] as num?)?.toInt(),
    gender: json['gender'] as String?,
    heightCm: (json['heightCm'] as num?)?.toDouble(),
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    profileImagePath: json['profileImagePath'] as String?,
  );

  static T _enumOrDefault<T extends Enum>(
    List<T> values,
    Object? value,
    T fallback,
  ) {
    for (final item in values) {
      if (item.name == value) return item;
    }
    return fallback;
  }
}
