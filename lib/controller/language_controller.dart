import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  // Default locale
  Locale initialLocale = const Locale('en', 'US');

  // Supported locales
  final List<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('es', 'ES'),
  ];

  // Observable for current language code
  var langCode = 'en'.obs;

  // Observable to check if language has been loaded
  var isLanguageLoaded = false.obs;

  // Load language preference from SharedPreferences
  @override
  void onInit() {
    super.onInit();
    loadLanguagePreference();
  }

  // Load the saved language preference
  Future<void> loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLang = prefs.getString('language');

    if (savedLang != null) {
      langCode.value = savedLang;
      initialLocale = Locale(savedLang);
      updateLocale(savedLang);
    } else {
      // If no saved language, default to 'en'
      langCode.value = 'en';
      updateLocale('en');
    }
    
    isLanguageLoaded.value = true;  // Mark as loaded
  }

  // Change the language and save preference
  void changeLanguage(String newLangCode) async {
    langCode.value = newLangCode;
    initialLocale = Locale(newLangCode);
    updateLocale(newLangCode);

    // Save the language preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLangCode);
  }

  // Update the locale for the app
  void updateLocale(String langCode) {
    Locale locale;
    if (langCode == 'es') {
      locale = const Locale('es', 'ES');
    } else {
      locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }
}
