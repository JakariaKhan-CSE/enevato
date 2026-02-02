// lib/controllers/badge_controller.dart

import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/demo/demo_data.dart';
import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/local_cache_service.dart';


class BadgeController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find<AuthController>();
  Worker? _authWorker;
  var isLoading = true.obs;
  var badges = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  Future<void> fetchUserBadges(String username, {bool forceRefresh = false}) async {
    try {
      isLoading(true);
      if (_authController.isDemo.value) {
        badges.value = List<Map<String, dynamic>>.from(DemoData.badges);
        errorMessage.value = '';
        return;
      }
      final cacheKey = 'user_badges:$username';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(hours: 6),
        );
        if (cached != null) {
          badges.value = List<Map<String, dynamic>>.from(cached);
          errorMessage.value = '';
          isLoading(false);
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        errorMessage.value = 'Please sign in again.';
        return;
      }
      var fetchedBadges = await _apiService.getUserBadges(username);
      badges.value = List<Map<String, dynamic>>.from(fetchedBadges);
      await LocalCacheService.write(cacheKey, fetchedBadges);
      errorMessage.value = '';
    } catch (e) {
      print("Error fetching badges: $e");
      badges.value = [];
      errorMessage.value = 'Error fetching badges: $e';
    } finally {
      isLoading(false);
    }
  }

  void bindToAuth(String username) {
    _authController.waitForReady().then((_) {
      if (_authController.isDemo.value ||
          _authController.accessToken.isNotEmpty) {
        fetchUserBadges(username);
      }
    });
    _authWorker?.dispose();
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        return;
      }
      fetchUserBadges(username);
    });
  }

  @override
  void onClose() {
    _authWorker?.dispose();
    super.onClose();
  }
}
