import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  arabic('ar', 'العربية', TextDirection.rtl),
  english('en', 'English', TextDirection.ltr);

  final String code;
  final String label;
  final TextDirection direction;

  const AppLanguage(this.code, this.label, this.direction);
}

class LocaleNotifier extends Notifier<AppLanguage> {
  static const String _prefKey = 'kalo_selected_language';

  @override
  AppLanguage build() {
    final bool isInTest = !kIsWeb &&
        (Platform.environment.containsKey('FLUTTER_TEST') ||
            const bool.fromEnvironment('flutter.test'));
    if (isInTest) {
      return AppLanguage.english;
    }
    Future.microtask(() => _loadLanguage());
    return AppLanguage.arabic;
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'en') {
        state = AppLanguage.english;
      } else {
        state = AppLanguage.arabic;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    if (state == AppLanguage.arabic) {
      await setLanguage(AppLanguage.english);
    } else {
      await setLanguage(AppLanguage.arabic);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLanguage>(LocaleNotifier.new);

class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'app_name': {
      'ar': 'كالـو',
      'en': 'KALO',
    },
    'app_subtitle': {
      'ar': 'ذكاء اصطناعي لحساب السعرات والماكروز بدقة',
      'en': 'AI-Powered Nutrition & Calorie Intelligence',
    },
    'sign_in': {
      'ar': 'تسجيل الدخول',
      'en': 'Sign In',
    },
    'sign_up': {
      'ar': 'إنشاء حساب جديد',
      'en': 'Create Account',
    },
    'email': {
      'ar': 'البريد الإلكتروني',
      'en': 'Email Address',
    },
    'password': {
      'ar': 'كلمة المرور',
      'en': 'Password',
    },
    'email_hint': {
      'ar': 'name@example.com',
      'en': 'name@example.com',
    },
    'password_hint': {
      'ar': '••••••••',
      'en': '••••••••',
    },
    'dont_have_account': {
      'ar': 'ليس لديك حساب؟ أنشئ حسابك الآن',
      'en': 'Don\'t have an account? Sign up',
    },
    'already_have_account': {
      'ar': 'لديك حساب بالفعل؟ سجل دخولك',
      'en': 'Already have an account? Sign in',
    },
    'auth_error': {
      'ar': 'فشل تسجيل الدخول، يرجى التحقق من البيانات',
      'en': 'Authentication failed. Please verify credentials.',
    },
    'auth_fill_all': {
      'ar': 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      'en': 'Please enter both email and password.',
    },
    'hey': {
      'ar': 'مرحباً',
      'en': 'Hey',
    },
    'champion': {
      'ar': 'بطل',
      'en': 'Champion',
    },
    'today_nutrition': {
      'ar': 'تغذية اليوم',
      'en': 'TODAY\'S NUTRITION',
    },
    'remaining': {
      'ar': 'متبقي',
      'en': 'Remaining',
    },
    'consumed': {
      'ar': 'مستهلك',
      'en': 'Consumed',
    },
    'budget': {
      'ar': 'الهدف اليومي',
      'en': 'Daily Budget',
    },
    'kcal': {
      'ar': 'سعرة',
      'en': 'kcal',
    },
    'protein': {
      'ar': 'البروتين',
      'en': 'Protein',
    },
    'carbs': {
      'ar': 'الكارب',
      'en': 'Carbs',
    },
    'fat': {
      'ar': 'الدهون',
      'en': 'Fat',
    },
    'g': {
      'ar': 'جم',
      'en': 'g',
    },
    'logged_meals': {
      'ar': 'وجبات اليوم',
      'en': 'Today\'s Meals',
    },
    'no_meals_today': {
      'ar': 'لا توجد وجبات مسجلة اليوم',
      'en': 'No meals logged yet today',
    },
    'start_tracking_hint': {
      'ar': 'التقط صورة لطبقك ليقوم الذكاء الاصطناعي بحساب السعرات والماكروز تلقائياً',
      'en': 'Snap a photo of your plate to automatically calculate calories & macros',
    },
    'scan_meal_button': {
      'ar': 'التقط وجبة الآن',
      'en': 'Scan Meal Now',
    },
    'days_streak': {
      'ar': 'أيام متتالية',
      'en': 'DAYS STREAK',
    },
    'camera_title': {
      'ar': 'ماسح الوجبات الذكي',
      'en': 'AI Food Scanner',
    },
    'point_camera_hint': {
      'ar': 'وجّه الكاميرا نحو الوجبة بوضوح',
      'en': 'Point camera at your meal clearly',
    },
    'snap_photo': {
      'ar': 'التقاط صورة',
      'en': 'Take Photo',
    },
    'pick_gallery': {
      'ar': 'من الاستوديو',
      'en': 'From Gallery',
    },
    'confirm_and_scan': {
      'ar': 'تحليل الوجبة بالذكاء الاصطناعي',
      'en': 'Analyze with AI',
    },
    'retake_photo': {
      'ar': 'إعادة الالتقاط',
      'en': 'Retake Photo',
    },
    'analyzing_image': {
      'ar': 'جاري تحليل الطبق والتعرف على السعرات والماكروز...',
      'en': 'Analyzing plate and identifying calories & macros...',
    },
    'not_food_error': {
      'ar': 'لم يتم التعرف على طعام في الصورة. يرجى التقاط صورة واضحة للوجبة.',
      'en': 'No food detected in this image. Please take a clearer photo of your meal.',
    },
    'scan_error_retry': {
      'ar': 'تعذر الاتصال بالذكاء الاصطناعي، يرجى التأكد من اتصال الإنترنت والمحاولة مجدداً.',
      'en': 'Failed to connect to AI. Please check internet connection and retry.',
    },
    'meal_result_title': {
      'ar': 'نتيجة المسح الذكي',
      'en': 'AI Scan Result',
    },
    'health_score': {
      'ar': 'درجة الصحة',
      'en': 'Health Score',
    },
    'ingredients_breakdown': {
      'ar': 'مكونات الوجبة المقدرة',
      'en': 'Estimated Ingredients Breakdown',
    },
    'save_to_diary': {
      'ar': 'تسجيل في يومياتي',
      'en': 'Save to Diary',
    },
    'meal_saved_toast': {
      'ar': 'تم تسجيل الوجبة بنجاح في سجل يومك!',
      'en': 'Meal saved to your daily diary!',
    },
    'settings_title': {
      'ar': 'الإعدادات',
      'en': 'Settings',
    },
    'account_section': {
      'ar': 'الحساب',
      'en': 'Account',
    },
    'language_switch': {
      'ar': 'لغة التطبيق',
      'en': 'App Language',
    },
    'daily_goals': {
      'ar': 'الأهداف الغذائية اليومية',
      'en': 'Daily Nutrition Goals',
    },
    'target_calories': {
      'ar': 'هدف السعرات اليومي (سعرة)',
      'en': 'Daily Calorie Target (kcal)',
    },
    'target_protein': {
      'ar': 'هدف البروتين (جم)',
      'en': 'Protein Target (g)',
    },
    'target_carbs': {
      'ar': 'هدف الكاربوهيدرات (جم)',
      'en': 'Carbohydrates Target (g)',
    },
    'target_fat': {
      'ar': 'هدف الدهون (جم)',
      'en': 'Fats Target (g)',
    },
    'save_goals': {
      'ar': 'حفظ الأهداف',
      'en': 'Save Goals',
    },
    'goals_saved': {
      'ar': 'تم تحديث أهدافك الغذائية بنجاح!',
      'en': 'Goals updated successfully!',
    },
    'sign_out': {
      'ar': 'تسجيل الخروج',
      'en': 'Sign Out',
    },
    'sign_out_confirm': {
      'ar': 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
      'en': 'Are you sure you want to sign out?',
    },
    'confirm': {
      'ar': 'تأكيد',
      'en': 'Confirm',
    },
    'cancel': {
      'ar': 'إلغاء',
      'en': 'Cancel',
    },
    'delete_meal': {
      'ar': 'حذف الوجبة',
      'en': 'Delete Meal',
    },
    'delete_meal_confirm': {
      'ar': 'هل تود حذف هذه الوجبة من سجلك اليوم؟',
      'en': 'Do you want to delete this meal from today\'s log?',
    },
    'water_tracker': {
      'ar': 'شرب الماء',
      'en': 'Hydration Tracker',
    },
    'fasting_tracker': {
      'ar': 'الصيام المتقطع',
      'en': 'Intermittent Fasting',
    },
    'glasses': {
      'ar': 'أكواب',
      'en': 'glasses',
    },
    'fasting_status_active': {
      'ar': 'فترة الصيام جارية',
      'en': 'Fasting in progress',
    },
    'fasting_status_idle': {
      'ar': 'نافذة الأكل مفتوحة',
      'en': 'Eating window open',
    },
    'meal_breakdown': {
      'ar': 'تفاصيل الوجبة',
      'en': 'Meal Breakdown',
    },
    'confirm_log_meal': {
      'ar': 'تأكيد وحفظ الوجبة',
      'en': 'Confirm & Log Meal',
    },
    'plate_ingredients': {
      'ar': 'مكونات الطبق',
      'en': 'Plate Ingredients',
    },
    'tap_to_adjust': {
      'ar': 'اضغط لتعديل الكميات',
      'en': 'Tap to adjust portions',
    },
    'visual_confidence': {
      'ar': 'تم التعرف بالذكاء الاصطناعي بدقة عالية',
      'en': 'Identified with 94% visual confidence',
    },
    'nutritional_quality': {
      'ar': 'تحليل جودة التغذية',
      'en': 'Nutritional Quality Analysis',
    },
    'added_sugar': {
      'ar': 'السكر المضاف',
      'en': 'Added Sugar',
    },
    'optimal': {
      'ar': 'مثالي (<2جم)',
      'en': 'Optimal (<2g)',
    },
    'processing_level': {
      'ar': 'مستوى المعالجة',
      'en': 'Processing Level',
    },
    'whole_ingredients': {
      'ar': 'مكونات طبيعية وكاملة',
      'en': 'Whole, natural ingredients',
    },
    'sodium_content': {
      'ar': 'محتوى الصوديوم',
      'en': 'Sodium Content',
    },
    'balanced': {
      'ar': 'معتدل ومتوازن',
      'en': 'Moderate & balanced',
    },
    'guest_mode': {
      'ar': 'المتابعة كضيف',
      'en': 'Continue as Guest',
    },
    'onboarding_welcome_badge': {
      'ar': 'ذكاء اصطناعي فائق للتغذية',
      'en': 'PRECISION AI NUTRITION',
    },
    'onboarding_welcome_title': {
      'ar': 'صوّر وجبتك.\nكالـو يحسب كل شيء.',
      'en': 'Snap your meal.\nKalo tracks everything.',
    },
    'onboarding_welcome_subtitle': {
      'ar': 'بدون بحث يدوي أو ميزان طعام. وجّه الكاميرا ودع الذكاء الاصطناعي يتعرف على المكونات والسعرات والماكروز في ثوانٍ.',
      'en': 'No tedious searching. No kitchen scales. Point your camera and let AI detect ingredients, calories, and macros in seconds.',
    },
    'onboarding_demo_label': {
      'ar': 'محاكاة التعرف الذكي الفوري',
      'en': 'AI Visual Detection Simulation',
    },
    'onboarding_demo_dish': {
      'ar': 'صدر دجاج مشوي مع أرز بسمتي وخضار',
      'en': 'Grilled Chicken Breast, Basmati & Greens',
    },
    'onboarding_demo_cal': {
      'ar': '520 سعرة',
      'en': '520 kcal',
    },
    'onboarding_demo_p': {
      'ar': '46جم بروتين',
      'en': '46g Protein',
    },
    'onboarding_demo_c': {
      'ar': '54جم كارب',
      'en': '54g Carbs',
    },
    'onboarding_demo_f': {
      'ar': '11جم دهون',
      'en': '11g Fat',
    },
    'onboarding_demo_confidence': {
      'ar': 'دقة التعرف البصري: 96%',
      'en': 'Visual AI Confidence: 96%',
    },
    'onboarding_get_started': {
      'ar': 'ابدأ الآن',
      'en': 'Get Started',
    },
    'onboarding_goal_title': {
      'ar': 'ما هو هدفك الأساسي؟',
      'en': 'What is your primary goal?',
    },
    'onboarding_goal_subtitle': {
      'ar': 'سنخصص ميزانيتك اليومية من السعرات والماكروز بدقة لتحقيق هدفك.',
      'en': 'We calibrate your daily caloric target and macro split around this goal.',
    },
    'goal_lose_weight': {
      'ar': 'خسارة الوزن',
      'en': 'Lose Weight',
    },
    'goal_lose_weight_desc': {
      'ar': 'حرق الدهون بعجز سعرات صحي ومستدام',
      'en': 'Burn fat with a sustained, healthy caloric deficit',
    },
    'goal_build_muscle': {
      'ar': 'بناء العضلات',
      'en': 'Build Muscle',
    },
    'goal_build_muscle_desc': {
      'ar': 'زيادة الكتلة العضلية مع تلبية احتياج البروتين',
      'en': 'Gain lean muscle with optimal protein synthesis',
    },
    'goal_maintain': {
      'ar': 'المحافظة على الوزن',
      'en': 'Maintain Weight',
    },
    'goal_maintain_desc': {
      'ar': 'موازنة استهلاك الطاقة وتحسين الصحة الأيضية',
      'en': 'Balance energy intake and optimize metabolic health',
    },
    'goal_eat_healthier': {
      'ar': 'تناول طعام صحي',
      'en': 'Eat Healthier',
    },
    'goal_eat_healthier_desc': {
      'ar': 'تحسين جودة الطعام ومغذياته دون قيود قاسية',
      'en': 'Enhance nutrient density and overall diet quality',
    },
    'onboarding_barrier_title': {
      'ar': 'ما أكبر تحدٍ واجهك سابقاً؟',
      'en': 'What stopped you in the past?',
    },
    'onboarding_barrier_subtitle': {
      'ar': 'صُمم كالـو خصيصاً لإلغاء أي عناء وجعل الالتزام سهلاً وتلقائياً.',
      'en': 'Kalo is engineered specifically to eliminate tracking friction.',
    },
    'barrier_too_long': {
      'ar': 'التسجيل اليدوي يستغرق وقتاً طويلاً',
      'en': 'Manual logging takes too long',
    },
    'barrier_too_long_desc': {
      'ar': 'البحث عن المكونات وإدخال الأوزان كان يسبب الملل',
      'en': 'Searching databases for every single ingredient',
    },
    'barrier_forget': {
      'ar': 'أنسى تسجيل الوجبات بانتظام',
      'en': 'I forget to log meals',
    },
    'barrier_forget_desc': {
      'ar': 'التطبيقات المعقدة يصعب الاستمرار عليها يومياً',
      'en': 'Complicated interfaces make daily adherence hard',
    },
    'barrier_portions': {
      'ar': 'صعوبة تقدير كميات الطعام والمطاعم',
      'en': 'Inaccurate portion estimates',
    },
    'barrier_portions_desc': {
      'ar': 'عدم معرفة الأوزان الدقيقة للوجبات الجاهزة',
      'en': 'Uncertainty about oils, sauces, and restaurant grams',
    },
    'onboarding_bio_title': {
      'ar': 'العمر والجنس البيولوجي',
      'en': 'Biological Sex & Age',
    },
    'onboarding_bio_subtitle': {
      'ar': 'عوامل علمية أساسية لحساب معدل الأيض القاعدي (BMR).',
      'en': 'Essential factors for determining baseline energy expenditure.',
    },
    'gender_male': {
      'ar': 'ذكر',
      'en': 'Male',
    },
    'gender_female': {
      'ar': 'أنثى',
      'en': 'Female',
    },
    'age_title': {
      'ar': 'العمر',
      'en': 'Age',
    },
    'years_old': {
      'ar': 'سنة',
      'en': 'years old',
    },
    'onboarding_measurements_title': {
      'ar': 'قياساتك الحالية',
      'en': 'Your Measurements',
    },
    'onboarding_measurements_subtitle': {
      'ar': 'تُستخدم لحساب معدل استهلاك الطاقة اليومي بدقة.',
      'en': 'Used to calculate your Basal Metabolic Rate (BMR).',
    },
    'unit_metric': {
      'ar': 'متري (سم / كجم)',
      'en': 'Metric (cm / kg)',
    },
    'unit_imperial': {
      'ar': 'إمبراطوري (قدم / باوند)',
      'en': 'Imperial (ft / lbs)',
    },
    'height_label': {
      'ar': 'الطول',
      'en': 'Height',
    },
    'weight_label': {
      'ar': 'الوزن الحالي',
      'en': 'Current Weight',
    },
    'onboarding_target_title': {
      'ar': 'الوزن المستهدف والوتيرة',
      'en': 'Target Weight & Pace',
    },
    'onboarding_target_subtitle': {
      'ar': 'اختر الوتيرة المناسبة لنمط حياتك لضمان ثبات النتائج.',
      'en': 'Choose a sustainable deficit pace to preserve lean muscle.',
    },
    'target_weight_label': {
      'ar': 'الهدف',
      'en': 'Target Goal',
    },
    'pace_steady': {
      'ar': 'وتيرة هادئة ومريحة',
      'en': 'Steady & Gentle',
    },
    'pace_steady_desc': {
      'ar': '0.25 كجم / أسبوع • عجز خفيف جداً وبدون جوع',
      'en': '0.25 kg / week • Minimal hunger deficit',
    },
    'pace_balanced': {
      'ar': 'وتيرة متوازنة (الموصى بها)',
      'en': 'Balanced (Recommended)',
    },
    'pace_balanced_desc': {
      'ar': '0.50 كجم / أسبوع • المعدل الذهبي المثالي طبياً',
      'en': '0.50 kg / week • Clinical standard for sustainable fat loss',
    },
    'pace_fast': {
      'ar': 'وتيرة مكثفة',
      'en': 'Intensive Pace',
    },
    'pace_fast_desc': {
      'ar': '0.75 كجم / أسبوع • انضباط غذائي أعلى',
      'en': '0.75 kg / week • Strict caloric adherence',
    },
    'onboarding_activity_title': {
      'ar': 'مستوى نشاطك البدني',
      'en': 'Physical Activity Level',
    },
    'onboarding_activity_subtitle': {
      'ar': 'يُضرب بمعدل BMR لحساب إجمالي استهلاك الطاقة اليومي (TDEE).',
      'en': 'Multiplied by BMR to calculate Total Daily Energy Expenditure (TDEE).',
    },
    'activity_light': {
      'ar': '0 - 2 تمرين أسبوعياً',
      'en': '0 - 2 workouts / week',
    },
    'activity_light_desc': {
      'ar': 'نمط حياة مكتبي أو حركة خفيفة',
      'en': 'Mostly sedentary routine or light walking',
    },
    'activity_moderate': {
      'ar': '3 - 5 تمارين أسبوعياً',
      'en': '3 - 5 workouts / week',
    },
    'activity_moderate_desc': {
      'ar': 'تمارين مقاومة أو جري أو رياضة منتظمة',
      'en': 'Regular gym workouts, running, or active sports',
    },
    'activity_intense': {
      'ar': '6+ تمارين أسبوعياً',
      'en': '6+ workouts / week',
    },
    'activity_intense_desc': {
      'ar': 'تدريب رياضي مكثف أو عمل بدني مجهد',
      'en': 'High-intensity athletic training or physically demanding job',
    },
    'onboarding_plan_title': {
      'ar': 'خطتك الغذائية العلمية',
      'en': 'Your Custom Nutrition Plan',
    },
    'onboarding_plan_subtitle': {
      'ar': 'تم حساب خطتك بدقة وفق معادلة ميفلين-سانت جور (Mifflin-St Jeor).',
      'en': 'Clinically calculated using the Mifflin-St Jeor equation.',
    },
    'metric_bmr': {
      'ar': 'معدل الأيض الأساسي (BMR)',
      'en': 'Basal Metabolic Rate (BMR)',
    },
    'metric_bmr_desc': {
      'ar': 'سعرات حرق الجسم أثناء الراحة التامة',
      'en': 'Calories burned at rest for basic biological functions',
    },
    'metric_tdee': {
      'ar': 'إجمالي حرق الطاقة (TDEE)',
      'en': 'Total Energy Expenditure (TDEE)',
    },
    'metric_tdee_desc': {
      'ar': 'إجمالي استهلاك السعرات مع احتساب النشاط',
      'en': 'Daily caloric burn including physical activity',
    },
    'daily_budget': {
      'ar': 'هدفك اليومي من السعرات',
      'en': 'Daily Caloric Target',
    },
    'daily_macros': {
      'ar': 'توزيع الماكروز اليومي',
      'en': 'Target Macro Distribution',
    },
    'projected_timeline': {
      'ar': 'التوقع الزمني للوصول لهدفك',
      'en': 'Projected Target Timeline',
    },
    'projected_reach_date': {
      'ar': 'الوصول المتوقع لهدفك في',
      'en': 'Estimated achievement date',
    },
    'start_journey': {
      'ar': 'اعتماد الخطة والمتابعة',
      'en': 'Accept Plan & Continue',
    },
    'continue_label': {
      'ar': 'متابعة',
      'en': 'Continue',
    },
    'back_label': {
      'ar': 'رجوع',
      'en': 'Back',
    },
    'switch_language': {
      'ar': 'English',
      'en': 'العربية',
    },
  };

  static String get(String key, AppLanguage lang) {
    final entry = _strings[key];
    if (entry == null) return key;
    return entry[lang.code] ?? entry['en'] ?? key;
  }
}

extension AppLocalizationExtension on BuildContext {
  String tr(WidgetRef ref, String key) {
    final lang = ref.watch(localeProvider);
    return AppStrings.get(key, lang);
  }

  AppLanguage lang(WidgetRef ref) {
    return ref.watch(localeProvider);
  }

  bool isArabic(WidgetRef ref) {
    return ref.watch(localeProvider) == AppLanguage.arabic;
  }
}
