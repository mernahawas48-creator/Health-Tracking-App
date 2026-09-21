import 'package:flutter/widgets.dart';
import 'package:meditrack/services/app_settings_controller.dart';

class AppStrings {
  const AppStrings._(this.languageCode);

  final String languageCode;

  bool get isArabic => languageCode == 'ar';

  static AppStrings of(BuildContext context) {
    return AppStrings._(AppSettingsScope.of(context).settings.languageCode);
  }

  String text(String key) =>
      (_values[languageCode] ?? _values['en']!)[key] ?? key;

  static const _values = <String, Map<String, String>>{
    'en': {
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'onboarding1Title': 'Never miss your medicines again',
      'onboarding1Description':
          'With gentle reminders delivered at just the right time.',
      'onboarding2Title': 'Keep your health on track',
      'onboarding2Description':
          'Track your health and stay on top of your daily habits.',
      'onboarding3Title': 'Build healthier habits',
      'onboarding3Description':
          'Create healthy routines and take better care of yourself.',
      'settings': 'Settings',
      'goals': 'Goals',
      'dailyGoals': 'Daily goals',
      'appearanceLanguage': 'Appearance and language',
      'theme': 'Theme',
      'systemDefault': 'System default',
      'light': 'Light',
      'dark': 'Dark',
      'units': 'Units',
      'measurementUnits': 'Measurement units',
      'metric': 'Metric (ml, kg, km)',
      'imperial': 'Imperial (fl oz, lb, mi)',
      'savedDevice': 'Preferences are saved on this device.',
      'dailyGoalsTitle': 'Daily goals',
      'waterGoal': 'Water goal',
      'sleepGoal': 'Sleep goal',
      'activeCaloriesGoal': 'Active calories goal',
      'dailyFoodGoal': 'Daily food goal',
      'hours': 'hours',
      'saveGoals': 'Save goals',
      'invalidGoals': 'Please enter realistic values for every goal.',
    },
    'ar': {
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'skip': 'تخطي',
      'next': 'التالي',
      'getStarted': 'ابدأ الآن',
      'onboarding1Title': 'لن تنسى أدويتك مرة أخرى',
      'onboarding1Description': 'تذكيرات لطيفة تصلك في الوقت المناسب.',
      'onboarding2Title': 'تابع صحتك باستمرار',
      'onboarding2Description': 'تابع صحتك وابقَ ملتزمًا بعاداتك اليومية.',
      'onboarding3Title': 'ابنِ عادات صحية',
      'onboarding3Description': 'أنشئ روتينًا صحيًا واهتم بنفسك بشكل أفضل.',
      'settings': 'الإعدادات',
      'goals': 'الأهداف',
      'dailyGoals': 'الأهداف اليومية',
      'appearanceLanguage': 'المظهر واللغة',
      'theme': 'المظهر',
      'systemDefault': 'إعداد الجهاز',
      'light': 'فاتح',
      'dark': 'داكن',
      'units': 'الوحدات',
      'measurementUnits': 'وحدات القياس',
      'metric': 'متري (مل، كجم، كم)',
      'imperial': 'إمبراطوري (أونصة، رطل، ميل)',
      'savedDevice': 'يتم حفظ التفضيلات على هذا الجهاز.',
      'dailyGoalsTitle': 'الأهداف اليومية',
      'waterGoal': 'هدف الماء',
      'sleepGoal': 'هدف النوم',
      'activeCaloriesGoal': 'هدف السعرات النشطة',
      'dailyFoodGoal': 'هدف السعرات اليومية',
      'hours': 'ساعات',
      'saveGoals': 'حفظ الأهداف',
      'invalidGoals': 'من فضلك أدخل قيماً مناسبة لكل الأهداف.',
    },
  };
}
