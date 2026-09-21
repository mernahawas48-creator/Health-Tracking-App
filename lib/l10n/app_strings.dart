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

  String waterStreak(int days) => isArabic
      ? '🔥 سلسلة شرب الماء: $days يوم'
      : '🔥 $days day water streak';

  String sleepStreak(int days) => isArabic
      ? '🔥 سلسلة نوم صحي: $days يوم'
      : '🔥 $days day healthy-sleep streak';

  String dayStreak(int days) =>
      isArabic ? '🔥 سلسلة $days يوم' : '🔥 $days day streak';

  String waterGoalDescription(int goalMl) => isArabic
      ? 'من هدف يومي قدره $goalMl مل'
      : 'of $goalMl ml daily goal';

  String waterRemaining(int remainingMl) => isArabic
      ? 'متبقي $remainingMl مل اليوم'
      : '$remainingMl ml remaining today';

  String nextWaterTarget(int amountMl) => isArabic
      ? 'الهدف اللطيف التالي: اشرب $amountMl مل خلال الساعتين القادمتين.'
      : 'Next gentle target: drink $amountMl ml in the next 2 hours.';

  String waterBehindPace(int amountMl) => isArabic
      ? 'أنت متأخر بمقدار $amountMl مل عن الوتيرة المنتظمة. كوب واحد مخطط سيساعدك على الاقتراب.'
      : 'You are $amountMl ml behind a steady pace. One planned drink is enough to get closer.';

  String medicationType(String type) => text('medType_$type');
  String medicationFrequency(String frequency) => text('medFrequency_$frequency');
  String mealRelation(String relation) => text('mealRelation_$relation');
  String doseStatus(String status) => text('doseStatus_$status');

  String medicationProgress({required int taken, required int total}) => isArabic
      ? 'تم تناول $taken من $total جرعات اليوم.'
      : '$taken of $total doses taken today.';

  String medicationHomeProgress({required int taken, required int total, required int streak}) => isArabic
      ? 'تم تناول $taken/$total جرعات • سلسلة $streak يوم'
      : '$taken/$total doses taken • $streak day streak';

  String caloriesRemaining(int calories) => isArabic
      ? 'متبقي $calories سعرة حرارية'
      : '$calories kcal remaining';

  String nutritionSummary({required int calories, required int protein}) => isArabic
      ? '$calories سعرة حرارية • بروتين $protein جم'
      : '$calories kcal • Protein ${protein}g';

  String mealLabel(String meal) => text('meal_$meal');
  String mealIdea(String name) => text('idea_$name');
  String ingredient(String name) => text('ingredient_$name');

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
      'welcome': 'Welcome', 'home': 'Home', 'meds': 'Meds', 'nutrition': 'Nutrition', 'profile': 'Profile', 'activity': 'Activity', 'water': 'Water', 'sleep': 'Sleep',
      'upcomingMedication': 'Upcoming Medication', 'noReminders': 'No reminders yet', 'addFirstMedication': 'Add your first medication', 'burnedCalories': 'Burned Calories', 'distance': 'Distance', 'steps': 'Steps', 'todayMedications': "Today's Medications", 'addAlert': 'Add Alert',
      'waterTracking': 'Water Tracking', 'reset': 'Reset', 'addWater': 'Add water', 'saveWater': "Save today's water", 'sleepSchedule': 'Sleep Schedule', 'bedtime': 'BEDTIME', 'wakeUp': 'WAKE UP', 'saveSleep': 'Save sleep schedule',
      'myMedications': 'My Medications', 'addMedication': 'Add medication', 'noMedications': 'No medications yet', 'todaySchedule': "Today's schedule", 'allMedications': 'All medications', 'taken': 'Taken', 'addMedicationTitle': 'Add Medication', 'medicationDetails': 'Medication details', 'medicationName': 'Medication name', 'dosage': 'Dosage', 'frequency': 'Frequency', 'startDate': 'Start date', 'reminderTime': 'Reminder time', 'saveMedication': 'Save Medication',
      'searchFood': 'Search food', 'todayCalories': "Today's calories", 'healthySuggestion': 'Healthy suggestion', 'todayMeals': "Today's meals", 'mealIdeas': 'Healthy meal ideas', 'addFood': 'Add food', 'meal': 'Meal', 'addToMeals': "Add to today's meals",
      'healthPlan': 'Your health plan', 'preferences': 'Preferences', 'personalDetails': 'Personal details', 'appSettings': 'App settings', 'support': 'Support', 'helpSupport': 'Help and support', 'privacy': 'Privacy', 'signOut': 'Sign out', 'editProfile': 'Edit profile', 'yourName': 'Your name', 'saveChanges': 'Save changes', 'profilePhoto': 'Profile photo', 'takePhoto': 'Take a photo', 'chooseFromGallery': 'Choose from gallery', 'editMedication': 'Edit medication', 'deleteMedication': 'Delete medication', 'deleteMedicationMessage': 'Remove this medication and its reminder?', 'cancel': 'Cancel', 'delete': 'Delete',
      'email': 'Email', 'password': 'Password', 'confirmPassword': 'Confirm Password', 'enterEmail': 'Enter your email', 'login': 'Log in', 'signUp': 'Sign up', 'needHelp': 'Need Help?', 'orContinue': 'or continue with',
      'firstTimeQuestion': 'Is this your first time?', 'yes': 'Yes', 'no': 'No',
      'enterEmailError': 'Please enter your email', 'validEmailError': 'Please enter a valid email', 'enterPasswordError': 'Please enter your password', 'passwordMismatch': 'Passwords do not match', 'passwordLengthError': 'Password must be at least 8 characters',
      'hydrationPace': 'Your hydration pace', 'hydratedToday': 'You are fully hydrated for today', 'healthyPace': 'You are on a healthy pace', 'catchUp': 'A small catch-up will help',
      'scheduledSleep': 'scheduled sleep', 'sleepGuide': 'Healthy sleep guide', 'sleepBelow': 'Below the recommended adult sleep range.', 'sleepRecommended': 'Great — this is the recommended 7–9 hour range.', 'sleepAbove': 'Above the usual 7–9 hour range for adults.',
      'noSleepLogged': 'No sleep logged', 'noMedicationsToday': 'No medications scheduled for today', 'nextReminder': 'Next reminder', 'allDosesCompleted': 'All doses completed', 'medicationAdherence': 'Medication adherence', 'noDosesToday': 'No doses are scheduled for today.', 'allDosesToday': 'Every scheduled dose was completed today.', 'markedAs': 'Marked as', 'asNeededNoReminder': 'As needed — no automatic reminder', 'addMedicationDescription': 'Set one reminder now. You can add more doses later.', 'exampleParacetamol': 'Example: Paracetamol', 'enterMedicationName': 'Enter the medication name', 'medicationType': 'Medication type', 'takeMedication': 'When do you take it?', 'lessThanSeven': '• Less than 7 hours: usually too little for most adults.', 'sevenToNine': '• 7–9 hours: the recommended adult range.', 'moreThanNine': '• More than 9 hours: may be more than most adults need.', 'waterGoalReached': "Great! You reached today's water goal.", 'waterGoalDoneMessage': 'Keep drinking when you feel thirsty, but there is no need to rush.', 'waterOnTrackMessage': 'Your intake is close to the pace needed to reach your goal by 10 PM.', 'waterPaceDisclaimer': 'Pace guide uses an 8 AM–10 PM day. It is a wellness guide, not medical advice.',
      'medType_tablet': 'Tablet', 'medType_capsule': 'Capsule', 'medType_injection': 'Injection', 'medType_drops': 'Drops', 'medType_syrup': 'Syrup', 'medType_inhaler': 'Inhaler', 'medType_cream': 'Cream', 'medType_other': 'Other', 'medFrequency_daily': 'Daily', 'medFrequency_everyOtherDay': 'Every other day', 'medFrequency_weekly': 'Weekly', 'medFrequency_asNeeded': 'As needed', 'mealRelation_beforeMeal': 'Before meal', 'mealRelation_afterMeal': 'After meal', 'mealRelation_anyTime': 'Any time', 'doseStatus_pending': 'Pending', 'doseStatus_taken': 'Taken', 'doseStatus_skipped': 'Skipped',
      'exampleDosage': 'Example: 500 mg or 2 tablets', 'enterDosage': 'Enter the dosage', 'asNeededDescription': 'As-needed medicines are saved but do not create automatic reminders.',
      'meal_breakfast': 'Breakfast', 'meal_lunch': 'Lunch', 'meal_dinner': 'Dinner', 'meal_snack': 'Snack', 'searchFoodHint': 'Search banana, chicken, rice...', 'foodLoadError': 'Could not load food data. Check your internet and API key.', 'searchFoodEmpty': 'Search for a food to see nutrition data.', 'noFilteredFoods': 'No foods match this filter.', 'all': 'All', 'generic': 'Generic', 'branded': 'Branded', 'servingAmount': 'Serving amount', 'grams': 'grams', 'noMealsLogged': 'No meals logged today', 'nutritionGoalReached': "You reached today's calorie goal. Choose water or a light snack if needed.", 'nutritionLightSuggestion': 'Light option: Greek yogurt with fruit, or an apple with a few nuts.', 'nutritionBalancedSuggestion': 'Balanced option: grilled chicken, vegetables, and a small serving of rice.', 'nutritionRoomSuggestion': 'You have room for a balanced meal: protein, vegetables, and a whole-grain carbohydrate.', 'suggestedForYou': 'Suggested for you', 'suggestionsDisclaimer': 'Suggestions are general wellness ideas, not medical or dietary advice.', 'remainingIdeas': 'These ideas fit your remaining target.', 'protein': 'Protein', 'carbs': 'Carbs', 'fat': 'Fat',
      'nameHealthGoal': 'Name and health goal', 'settingsDescription': 'Goals, theme, language and units', 'notifications': 'Notifications', 'notificationDescription': 'Medication and daily reminders', 'notificationsOff': 'Notifications are off', 'wellnessJourney': 'Your wellness journey', 'mainGoal': 'Main goal', 'activeKcal': 'Active kcal', 'healthTrackingApp': 'Health Tracking App', 'enterName': 'Enter your name', 'enterNameError': 'Please enter your name.', 'goalQuestion': 'What is your main goal?', 'goalBuildHabits': 'Build healthy habits', 'goalImproveSleep': 'Improve sleep', 'goalStayActive': 'Stay active', 'goalEatHealthier': 'Eat healthier', 'goalManageMedications': 'Manage medications', 'comingSoon': 'will be available soon.', 'loginWelcome': 'Hey, Welcome back!', 'loginSubtitle': 'Glad to see you, Again!', 'signupTitle': "Let's Sign up", 'passwordUppercase': 'Password must contain an uppercase letter', 'passwordLowercase': 'Password must contain a lowercase letter', 'passwordNumber': 'Password must contain a number',
      'healthFocus': 'Your focus', 'chooseGoals': 'Choose one or more health goals', 'goalHint': 'Select the areas you want the app to support.', 'noGoalsSelected': 'Choose your goals to personalize this plan.', 'focusMedication': 'Keep today’s medicine schedule up to date.', 'focusSleep': 'Aim for a consistent bedtime and wake-up time.', 'focusActivity': 'Build movement into your day, one step at a time.', 'focusNutrition': 'Choose balanced meals and log what you eat.', 'focusHabits': 'Small daily actions create lasting healthy habits.',
      'personalInformation': 'Personal information', 'age': 'Age', 'gender': 'Gender', 'height': 'Height', 'weight': 'Weight', 'selectGender': 'Select gender', 'female': 'Female', 'male': 'Male', 'preferNotToSay': 'Prefer not to say', 'years': 'years', 'cm': 'cm', 'kg': 'kg', 'invalidPersonalInfo': 'Enter a valid age, height, and weight.',
      'idea_Greek yogurt & berries': 'Greek yogurt & berries', 'idea_Apple & peanut butter': 'Apple & peanut butter', 'idea_Chicken rice bowl': 'Chicken rice bowl', 'idea_Tuna whole-grain sandwich': 'Tuna whole-grain sandwich', 'idea_Salmon & vegetables': 'Salmon & vegetables', 'idea_Lentil pasta bowl': 'Lentil pasta bowl',
      'ingredient_Greek yogurt': 'Greek yogurt', 'ingredient_Fresh berries': 'Fresh berries', 'ingredient_Chia seeds': 'Chia seeds', 'ingredient_Apple': 'Apple', 'ingredient_Natural peanut butter': 'Natural peanut butter', 'ingredient_Grilled chicken': 'Grilled chicken', 'ingredient_Brown rice': 'Brown rice', 'ingredient_Mixed vegetables': 'Mixed vegetables', 'ingredient_Tuna': 'Tuna', 'ingredient_Whole-grain bread': 'Whole-grain bread', 'ingredient_Lettuce and tomato': 'Lettuce and tomato', 'ingredient_Baked salmon': 'Baked salmon', 'ingredient_Sweet potato': 'Sweet potato', 'ingredient_Steamed broccoli': 'Steamed broccoli', 'ingredient_Lentil pasta': 'Lentil pasta', 'ingredient_Tomato sauce': 'Tomato sauce', 'ingredient_Side salad': 'Side salad',
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
      'welcome': 'مرحباً', 'home': 'الرئيسية', 'meds': 'الأدوية', 'nutrition': 'التغذية', 'profile': 'الملف الشخصي', 'activity': 'النشاط', 'water': 'الماء', 'sleep': 'النوم',
      'upcomingMedication': 'الدواء القادم', 'noReminders': 'لا توجد تذكيرات بعد', 'addFirstMedication': 'أضف أول دواء لك', 'burnedCalories': 'السعرات المحروقة', 'distance': 'المسافة', 'steps': 'الخطوات', 'todayMedications': 'أدوية اليوم', 'addAlert': 'إضافة تذكير',
      'waterTracking': 'متابعة الماء', 'reset': 'إعادة ضبط', 'addWater': 'إضافة ماء', 'saveWater': 'حفظ ماء اليوم', 'sleepSchedule': 'جدول النوم', 'bedtime': 'وقت النوم', 'wakeUp': 'وقت الاستيقاظ', 'saveSleep': 'حفظ جدول النوم',
      'myMedications': 'أدويتي', 'addMedication': 'إضافة دواء', 'noMedications': 'لا توجد أدوية بعد', 'todaySchedule': 'جدول اليوم', 'allMedications': 'كل الأدوية', 'taken': 'تم تناوله', 'addMedicationTitle': 'إضافة دواء', 'medicationDetails': 'تفاصيل الدواء', 'medicationName': 'اسم الدواء', 'dosage': 'الجرعة', 'frequency': 'التكرار', 'startDate': 'تاريخ البداية', 'reminderTime': 'وقت التذكير', 'saveMedication': 'حفظ الدواء',
      'searchFood': 'البحث عن طعام', 'todayCalories': 'سعرات اليوم', 'healthySuggestion': 'اقتراح صحي', 'todayMeals': 'وجبات اليوم', 'mealIdeas': 'أفكار وجبات صحية', 'addFood': 'إضافة طعام', 'meal': 'الوجبة', 'addToMeals': 'إضافة إلى وجبات اليوم',
      'healthPlan': 'خطتك الصحية', 'preferences': 'التفضيلات', 'personalDetails': 'البيانات الشخصية', 'appSettings': 'إعدادات التطبيق', 'support': 'الدعم', 'helpSupport': 'المساعدة والدعم', 'privacy': 'الخصوصية', 'signOut': 'تسجيل الخروج', 'editProfile': 'تعديل الملف الشخصي', 'yourName': 'اسمك', 'saveChanges': 'حفظ التغييرات', 'profilePhoto': 'صورة الملف الشخصي', 'takePhoto': 'التقاط صورة', 'chooseFromGallery': 'اختيار من المعرض', 'editMedication': 'تعديل الدواء', 'deleteMedication': 'حذف الدواء', 'deleteMedicationMessage': 'حذف هذا الدواء والتذكير الخاص به؟', 'cancel': 'إلغاء', 'delete': 'حذف',
      'email': 'البريد الإلكتروني', 'password': 'كلمة المرور', 'confirmPassword': 'تأكيد كلمة المرور', 'enterEmail': 'أدخل بريدك الإلكتروني', 'login': 'تسجيل الدخول', 'signUp': 'إنشاء حساب', 'needHelp': 'هل تحتاج إلى مساعدة؟', 'orContinue': 'أو المتابعة باستخدام',
      'firstTimeQuestion': 'هل هذه المرة الأولى لك؟', 'yes': 'نعم', 'no': 'لا',
      'enterEmailError': 'من فضلك أدخل بريدك الإلكتروني', 'validEmailError': 'من فضلك أدخل بريدًا إلكترونيًا صحيحًا', 'enterPasswordError': 'من فضلك أدخل كلمة المرور', 'passwordMismatch': 'كلمتا المرور غير متطابقتين', 'passwordLengthError': 'يجب أن تكون كلمة المرور 8 أحرف على الأقل',
      'hydrationPace': 'معدل شرب الماء', 'hydratedToday': 'لقد حققت هدف الماء اليوم', 'healthyPace': 'أنت تسير بمعدل جيد', 'catchUp': 'كمية بسيطة إضافية ستساعدك',
      'scheduledSleep': 'النوم المجدول', 'sleepGuide': 'دليل النوم الصحي', 'sleepBelow': 'أقل من نطاق النوم الموصى به للبالغين.', 'sleepRecommended': 'ممتاز — هذا ضمن المدى الموصى به من 7 إلى 9 ساعات.', 'sleepAbove': 'أعلى من المدى المعتاد من 7 إلى 9 ساعات للبالغين.',
      'noSleepLogged': 'لم يتم تسجيل نوم', 'noMedicationsToday': 'لا توجد أدوية مجدولة لليوم', 'nextReminder': 'التذكير القادم', 'allDosesCompleted': 'تم إكمال كل الجرعات', 'medicationAdherence': 'الالتزام بالدواء', 'noDosesToday': 'لا توجد جرعات مجدولة لليوم.', 'allDosesToday': 'تم إكمال كل الجرعات المجدولة اليوم.', 'markedAs': 'تم تحديدها كـ', 'asNeededNoReminder': 'عند الحاجة — بدون تذكير تلقائي', 'addMedicationDescription': 'أضف تذكيرًا واحدًا الآن. يمكنك إضافة جرعات أخرى لاحقًا.', 'exampleParacetamol': 'مثال: باراسيتامول', 'enterMedicationName': 'أدخل اسم الدواء', 'medicationType': 'نوع الدواء', 'takeMedication': 'متى تتناوله؟', 'lessThanSeven': '• أقل من 7 ساعات: غالبًا لا تكفي لمعظم البالغين.', 'sevenToNine': '• من 7 إلى 9 ساعات: المدى الموصى به للبالغين.', 'moreThanNine': '• أكثر من 9 ساعات: قد يكون أكثر مما يحتاجه معظم البالغين.', 'waterGoalReached': 'رائع! لقد حققت هدف الماء اليوم.', 'waterGoalDoneMessage': 'اشرب عند الشعور بالعطش، لكن لا داعي للاستعجال.', 'waterOnTrackMessage': 'كمية الماء قريبة من الوتيرة المطلوبة لتحقيق هدفك بحلول العاشرة مساءً.', 'waterPaceDisclaimer': 'يعتمد دليل الوتيرة على يوم من 8 صباحًا إلى 10 مساءً. وهو دليل للعافية وليس نصيحة طبية.',
      'medType_tablet': 'قرص', 'medType_capsule': 'كبسولة', 'medType_injection': 'حقنة', 'medType_drops': 'قطرات', 'medType_syrup': 'شراب', 'medType_inhaler': 'بخاخ', 'medType_cream': 'كريم', 'medType_other': 'أخرى', 'medFrequency_daily': 'يوميًا', 'medFrequency_everyOtherDay': 'يومًا بعد يوم', 'medFrequency_weekly': 'أسبوعيًا', 'medFrequency_asNeeded': 'عند الحاجة', 'mealRelation_beforeMeal': 'قبل الأكل', 'mealRelation_afterMeal': 'بعد الأكل', 'mealRelation_anyTime': 'في أي وقت', 'doseStatus_pending': 'قيد الانتظار', 'doseStatus_taken': 'تم تناوله', 'doseStatus_skipped': 'تم تخطيه',
      'exampleDosage': 'مثال: 500 ملجم أو قرصان', 'enterDosage': 'أدخل الجرعة', 'asNeededDescription': 'الأدوية عند الحاجة تُحفظ ولكن لا تنشئ تذكيرات تلقائية.',
      'meal_breakfast': 'الإفطار', 'meal_lunch': 'الغداء', 'meal_dinner': 'العشاء', 'meal_snack': 'وجبة خفيفة', 'searchFoodHint': 'ابحث عن موز أو دجاج أو أرز...', 'foodLoadError': 'تعذر تحميل بيانات الطعام. تحقق من الإنترنت ومفتاح API.', 'searchFoodEmpty': 'ابحث عن طعام لعرض بياناته الغذائية.', 'noFilteredFoods': 'لا توجد أطعمة تطابق هذا الفلتر.', 'all': 'الكل', 'generic': 'عام', 'branded': 'علامة تجارية', 'servingAmount': 'كمية الحصة', 'grams': 'جرام', 'noMealsLogged': 'لا توجد وجبات مسجلة اليوم', 'nutritionGoalReached': 'لقد وصلت إلى هدف السعرات اليوم. اختر الماء أو وجبة خفيفة عند الحاجة.', 'nutritionLightSuggestion': 'خيار خفيف: زبادي يوناني مع فاكهة، أو تفاحة مع بعض المكسرات.', 'nutritionBalancedSuggestion': 'خيار متوازن: دجاج مشوي وخضراوات وحصة صغيرة من الأرز.', 'nutritionRoomSuggestion': 'لديك مساحة لوجبة متوازنة: بروتين وخضراوات وكربوهيدرات من الحبوب الكاملة.', 'suggestedForYou': 'مقترحات لك', 'suggestionsDisclaimer': 'الاقتراحات أفكار عامة للعافية وليست نصائح طبية أو غذائية.', 'remainingIdeas': 'تتناسب هذه الأفكار مع هدفك المتبقي.', 'protein': 'البروتين', 'carbs': 'الكربوهيدرات', 'fat': 'الدهون',
      'nameHealthGoal': 'الاسم والهدف الصحي', 'settingsDescription': 'الأهداف والمظهر واللغة والوحدات', 'notifications': 'الإشعارات', 'notificationDescription': 'تذكيرات الدواء والمهام اليومية', 'notificationsOff': 'الإشعارات متوقفة', 'wellnessJourney': 'رحلتك نحو العافية', 'mainGoal': 'الهدف الأساسي', 'activeKcal': 'السعرات النشطة', 'healthTrackingApp': 'تطبيق متابعة الصحة', 'enterName': 'أدخل اسمك', 'enterNameError': 'من فضلك أدخل اسمك.', 'goalQuestion': 'ما هو هدفك الأساسي؟', 'goalBuildHabits': 'بناء عادات صحية', 'goalImproveSleep': 'تحسين النوم', 'goalStayActive': 'الحفاظ على النشاط', 'goalEatHealthier': 'تناول طعام صحي أكثر', 'goalManageMedications': 'إدارة الأدوية', 'comingSoon': 'سيتوفر قريبًا.', 'loginWelcome': 'مرحبًا بعودتك!', 'loginSubtitle': 'سعداء برؤيتك مرة أخرى!', 'signupTitle': 'أنشئ حسابًا', 'passwordUppercase': 'يجب أن تحتوي كلمة المرور على حرف كبير', 'passwordLowercase': 'يجب أن تحتوي كلمة المرور على حرف صغير', 'passwordNumber': 'يجب أن تحتوي كلمة المرور على رقم',
      'healthFocus': 'مجالات تركيزك', 'chooseGoals': 'اختاري هدفًا صحيًا أو أكثر', 'goalHint': 'حددي المجالات التي تريدين أن يدعمك التطبيق فيها.', 'noGoalsSelected': 'اختاري أهدافك لتخصيص هذه الخطة.', 'focusMedication': 'حافظي على تحديث جدول الأدوية اليوم.', 'focusSleep': 'حاولي الالتزام بوقت نوم واستيقاظ منتظم.', 'focusActivity': 'أضيفي حركة ليومك، خطوة في كل مرة.', 'focusNutrition': 'اختاري وجبات متوازنة وسجّلي ما تتناولينه.', 'focusHabits': 'الخطوات اليومية الصغيرة تصنع عادات صحية مستمرة.',
      'personalInformation': 'المعلومات الشخصية', 'age': 'العمر', 'gender': 'النوع', 'height': 'الطول', 'weight': 'الوزن', 'selectGender': 'اختاري النوع', 'female': 'أنثى', 'male': 'ذكر', 'preferNotToSay': 'أفضل عدم الإفصاح', 'years': 'سنة', 'cm': 'سم', 'kg': 'كجم', 'invalidPersonalInfo': 'أدخلي عمرًا وطولًا ووزنًا صحيحين.',
      'idea_Greek yogurt & berries': 'زبادي يوناني مع التوت', 'idea_Apple & peanut butter': 'تفاح وزبدة الفول السوداني', 'idea_Chicken rice bowl': 'طبق دجاج وأرز', 'idea_Tuna whole-grain sandwich': 'ساندويتش تونة بالحبوب الكاملة', 'idea_Salmon & vegetables': 'سلمون وخضراوات', 'idea_Lentil pasta bowl': 'طبق مكرونة العدس',
      'ingredient_Greek yogurt': 'زبادي يوناني', 'ingredient_Fresh berries': 'توت طازج', 'ingredient_Chia seeds': 'بذور الشيا', 'ingredient_Apple': 'تفاح', 'ingredient_Natural peanut butter': 'زبدة فول سوداني طبيعية', 'ingredient_Grilled chicken': 'دجاج مشوي', 'ingredient_Brown rice': 'أرز بني', 'ingredient_Mixed vegetables': 'خضراوات مشكلة', 'ingredient_Tuna': 'تونة', 'ingredient_Whole-grain bread': 'خبز بالحبوب الكاملة', 'ingredient_Lettuce and tomato': 'خس وطماطم', 'ingredient_Baked salmon': 'سلمون مخبوز', 'ingredient_Sweet potato': 'بطاطا حلوة', 'ingredient_Steamed broccoli': 'بروكلي مطهو على البخار', 'ingredient_Lentil pasta': 'مكرونة العدس', 'ingredient_Tomato sauce': 'صلصة طماطم', 'ingredient_Side salad': 'سلطة جانبية',
    },
  };
}
