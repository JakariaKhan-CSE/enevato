import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/local_cache_service.dart';


class MarketStatsController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController _authController = Get.find<AuthController>();
  late final Worker _authWorker;

  // Observables for storing fetched data
  var totalUsers = 0.obs;
  var totalItems = 0.obs;
  var numberOfFiles = <dynamic>[].obs; // To store number of files in categories
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authController.waitForReady().then((_) {
      if (_authController.accessToken.isNotEmpty) {
        fetchMarketStats();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        return;
      }
      fetchMarketStats();
    });
  }

  @override
  void onClose() {
    _authWorker.dispose();
    super.onClose();
  }

  // Method to fetch market statistics
  Future<void> fetchMarketStats({bool forceRefresh = false}) async {
    isLoading.value = true; // Set loading to true
    try {
      if (!forceRefresh) {
        final cachedUsers = LocalCacheService.read<int>(
          'market_total_users',
          maxAge: const Duration(hours: 12),
        );
        final cachedItems = LocalCacheService.read<int>(
          'market_total_items',
          maxAge: const Duration(hours: 12),
        );
        final cachedFiles = LocalCacheService.read<List<dynamic>>(
          'market_number_of_files:themeforest',
          maxAge: const Duration(hours: 12),
        );
        if (cachedUsers != null && cachedItems != null && cachedFiles != null) {
          totalUsers.value = cachedUsers;
          totalItems.value = cachedItems;
          numberOfFiles.assignAll(cachedFiles);
          return;
        }
      }
      // Fetch total users and items
      final users = await apiService.getTotalUsers();
      final items = await apiService.getTotalItems();
      totalUsers.value = users;
      totalItems.value = items;
      await LocalCacheService.write('market_total_users', users);
      await LocalCacheService.write('market_total_items', items);

      // Fetch number of files for a specific site (e.g., 'themeforest')
      final files = await apiService.getNumberOfFiles('themeforest');
      numberOfFiles.value = files;
      await LocalCacheService.write('market_number_of_files:themeforest', files);

    } catch (e) {
      print('Error fetching market stats: $e');
    } finally {
      isLoading.value = false; // Set loading to false after fetching
    }
  }
}
