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
