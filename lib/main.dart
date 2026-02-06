import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myenvato/bindings/binding.dart';
import 'package:myenvato/controller/language_controller.dart';
import 'package:get/get.dart';
import 'package:myenvato/extension/app_translations.dart';
import 'package:myenvato/screens/splash_screen.dart';
import 'package:myenvato/services/local_cache_service.dart';
import 'package:myenvato/theme/app_theme.dart';
import 'package:myenvato/widget/app_lifecycle_handler.dart';
import 'package:myenvato/widget/loading_shimmer.dart';
import 'package:toastification/toastification.dart';

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

void main() async {
  // Ensure flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await LocalCacheService.init();
  //await HomeWidgetService.init();
  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize LanguageController once
    final LanguageController languageController = Get.put(LanguageController());

    return Obx(() {
      // Only build the app after the language is loaded
      if (languageController.isLanguageLoaded.isFalse) {
        // Show a loading indicator while waiting for the language to load
        return const MaterialApp(
          home: Scaffold(
            body: LoadingShimmer(),
          ),
        );
      }

      // Build the app after the language has been successfully loaded
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return ToastificationWrapper(
            child: AppLifecycleHandler(
              child: GetMaterialApp(
                initialBinding: Binding(),
                translations: AppTranslations(),
                locale: languageController.initialLocale, // Use loaded locale
                fallbackLocale: const Locale('en', 'US'),
                debugShowCheckedModeBanner: false,
                title: 'Evacado Tracker',
                scrollBehavior: const _NoGlowScrollBehavior(),
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: ThemeMode.system,
                defaultTransition: Transition.fadeIn,
                transitionDuration: const Duration(milliseconds: 280),
                home: const SplashScreen(),
              ),
            ),
          );
        },
      );
    });
  }
}

// class DeepLinkHandler extends StatefulWidget {
//   @override
//   _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
// }

// class _DeepLinkHandlerState extends State<DeepLinkHandler> {
//   final AuthController authController = Get.find();

//   @override
//   void initState() {
//     super.initState();
//     // Listen for deep links
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final uri = Uri.base;
//       authController.handleRedirect(uri);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Envato OAuth Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             authController.initiateLogin();
//           },
//           child: Text('Sign In with Envato'),
//         ),
//       ),
//     );
//   }
// }
