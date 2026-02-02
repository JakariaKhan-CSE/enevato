import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/screens/auth/preload_screen.dart';
import 'package:myenvato/screens/auth/sign_in_screen.dart';
import 'package:myenvato/screens/home/bottom_nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  static const String _appName = 'Evacado Tracker';
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  Future<void> _navigateNext() async {
    await Future.delayed(Duration(seconds: 1));
    await _authController.waitForReady();
    if (!mounted) {
      return;
    }
    Widget nextScreen;
    if (_authController.isDemo.value) {
      nextScreen = BottomNavScreen();
    } else if (_authController.accessToken.isEmpty) {
      nextScreen = SignInScreen();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final preloadDone = prefs.getBool('preload_completed') ?? false;
      nextScreen = preloadDone ? BottomNavScreen() : const PreloadScreen();
    }
    Get.offAll(() => nextScreen);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
       backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.eco,
                color: colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
