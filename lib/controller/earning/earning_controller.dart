import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/demo/demo_data.dart';
import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/local_cache_service.dart';


class EarningsController extends GetxController {
  var earningsList = <Map<String, dynamic>>[].obs; // Observable list for earnings data
  var isLoading = true.obs; // Observable loading state
  var errorMessage = ''.obs; // Observable error message
  final AuthController _authController = Get.find<AuthController>();
  late final Worker _authWorker;

  @override
  void onInit() {
    super.onInit();
    _authController.waitForReady().then((_) {
      if (_authController.isDemo.value ||
          _authController.accessToken.isNotEmpty) {
        fetchEarningsAndSalesByMonth();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        if (_authController.isDemo.value) {
          fetchEarningsAndSalesByMonth();
        }
        return;
      }
      fetchEarningsAndSalesByMonth();
    });
  }

  @override
  void onClose() {
    _authWorker.dispose();
    super.onClose();
  }

  Future<void> fetchEarningsAndSalesByMonth({bool forceRefresh = false}) async {
    isLoading.value = true;
    try {
      if (_authController.isDemo.value) {
        earningsList.value = DemoData.earningsByMonth;
        errorMessage.value = '';
        return;
      }
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<Map<String, dynamic>>>(
          'earnings_by_month',
          maxAge: const Duration(minutes: 10),
        );
        if (cached != null) {
          earningsList.value = cached;
          errorMessage.value = '';
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        errorMessage.value = 'Please sign in again to load earnings data.';
        return;
      }
      final earnings = await ApiService().getEarningsAndSalesByMonth();
      final normalizedEarnings = earnings
          .map<Map<String, dynamic>>(
            (entry) => Map<String, dynamic>.from(entry as Map),
          )
          .toList();
      earningsList.value = normalizedEarnings;
      await LocalCacheService.write('earnings_by_month', normalizedEarnings);
      errorMessage.value = ''; // Clear any previous error messages
    } catch (e) {
      errorMessage.value = 'Error fetching earnings data: $e'; // Handle any errors
    } finally {
      isLoading.value = false; // Set loading to false after the operation
    }
  }
}
