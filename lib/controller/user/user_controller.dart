import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/demo/demo_data.dart';
import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/home_widget_service.dart';
import 'package:myenvato/services/local_cache_service.dart';

class UserController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find<AuthController>();
  late final Worker _authWorker;

  // Observable variable to store the total users count
  var totalUsers = 0.obs;
  var totalItems = 0.obs;
  final RxMap<String, dynamic> userDetails = <String, dynamic>{}.obs;
  var detailsLoading = false.obs;
  var detailsError = ''.obs;
  var userItems = [].obs; // Observable list to hold the user's items by site
  var userItemsLoading = false.obs;
  var userItemsError = ''.obs;
  var portfolioItems = <dynamic>[].obs;
  var portfolioLoading = false.obs;
  var portfolioError = ''.obs;
  var portfolioSiteItems = <dynamic>[].obs;
  var portfolioSiteLoading = false.obs;
  var portfolioSiteError = ''.obs;
  var errorMessage = ''.obs; // Observable to track error messages
  final RxMap<String, dynamic> userAccount = <String, dynamic>{}.obs; // Observable to hold user account details
  var accountLoading = false.obs;
  var accountError = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authController.waitForReady().then((_) {
      if (_authController.accessToken.isNotEmpty) {
        fetchUserAccount();
        fetchTotalUsers();
        fetchTotalItems();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        return;
      }
      fetchUserAccount();
      fetchTotalUsers();
      fetchTotalItems();
    });
  }

  @override
  void onClose() {
    _authWorker.dispose();
    super.onClose();
  }
// Fetch user details
  Future<void> fetchUserDetails(String username, {bool forceRefresh = false}) async {
    try {
      if (_authController.isDemo.value) {
        userDetails.assignAll(DemoData.userDetails);
        detailsError.value = '';
       // _pushWidgetSummaryFromDetails();
        return;
      }
      final cacheKey = 'user_details:$username';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<Map<String, dynamic>>(
          cacheKey,
          maxAge: const Duration(hours: 1),
        );
        if (cached != null) {
          userDetails.assignAll(cached);
          detailsError.value = '';
          detailsLoading.value = false;
          return;
        }
      }
      detailsLoading.value = true;
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        detailsError.value = 'Please sign in again.';
        return;
      }
      var data = await _apiService.getUserDetails(username);
      userDetails.value = data;
      await LocalCacheService.write(cacheKey, data);
     // _pushWidgetSummaryFromDetails();
      detailsError.value = '';
    } catch (e) {
      if (e is DioException) {
        print('User details error: status=${e.response?.statusCode}');
        print('User details response: ${e.response?.data}');
      } else {
        print('User details error: $e');
      }
      detailsError.value = 'Error fetching user details: $e';
    } finally {
      detailsLoading.value = false;
    }
  }

  // Function to fetch total users from the API
  Future<void> fetchTotalUsers({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = LocalCacheService.read<int>(
          'market_total_users',
          maxAge: const Duration(hours: 12),
        );
        if (cached != null) {
          totalUsers.value = cached;
          isLoading(false);
          return;
        }
      }
      isLoading(true);
      final total = await _apiService.getTotalUsers();
      totalUsers.value = total;
      await LocalCacheService.write('market_total_users', total);
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading(false);
    }
  }
  // Function to fetch total items from the API
  Future<void> fetchTotalItems({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = LocalCacheService.read<int>(
          'market_total_items',
          maxAge: const Duration(hours: 12),
        );
        if (cached != null) {
          totalItems.value = cached;
          isLoading(false);
          return;
        }
      }
      isLoading(true);
      final total = await _apiService.getTotalItems();
      totalItems.value = total;
      await LocalCacheService.write('market_total_items', total);
    } catch (e) {
      print('Error fetching total items: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch items for sale by site
  Future<void> fetchUserItemsBySite(String username, {bool forceRefresh = false}) async {
    userItemsLoading(true);
    try {
      if (_authController.isDemo.value) {
        userItems.assignAll(DemoData.portfolioSites);
        userItemsError.value = '';
        return;
      }
      final cacheKey = 'user_items_by_site:$username';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 30),
        );
        if (cached != null) {
          userItems.assignAll(cached);
          userItemsError.value = '';
          userItemsLoading(false);
          return;
        }
      }
      final items = await _apiService.getUserItemsBySite(username);
      userItems.assignAll(items); // Update the user items
      await LocalCacheService.write(cacheKey, items);
      userItemsError.value = '';
    } catch (e) {
      userItemsError.value = 'Error fetching portfolio sites: $e';
    } finally {
      userItemsLoading(false);
    }
  }

  Future<void> fetchPortfolioItems(String username, {bool forceRefresh = false}) async {
    portfolioLoading(true);
    try {
      final cacheKey = 'portfolio_items:$username';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 30),
        );
        if (cached != null) {
          portfolioItems.assignAll(cached);
          portfolioError.value = '';
          portfolioLoading(false);
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        portfolioError.value = 'Please sign in again.';
        return;
      }
      final items = await _apiService.getUserItems(username);
      portfolioItems.assignAll(items);
      await LocalCacheService.write(cacheKey, items);
      portfolioError.value = '';
    } catch (e) {
      portfolioError.value = 'Error fetching portfolio items: $e';
    } finally {
      portfolioLoading(false);
    }
  }

  Future<void> fetchPortfolioItemsBySite({
    required String username,
    required String site,
    bool forceRefresh = false,
  }) async {
    portfolioSiteLoading(true);
    try {
      if (_authController.isDemo.value) {
        portfolioSiteItems.assignAll(
          DemoData.portfolioItemsBySite[site] ?? const [],
        );
        portfolioSiteError.value = '';
        return;
      }
      final cacheKey = 'portfolio_items_by_site:$username:$site';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 15),
        );
        if (cached != null) {
          portfolioSiteItems.assignAll(cached);
          portfolioSiteError.value = '';
          portfolioSiteLoading(false);
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        portfolioSiteError.value = 'Please sign in again.';
        return;
      }
      final items = await _apiService.getNewFilesFromUser(
        username: username,
        site: site,
      );
      portfolioSiteItems.assignAll(items);
      await LocalCacheService.write(cacheKey, items);
      portfolioSiteError.value = '';
    } catch (e) {
      portfolioSiteError.value = 'Error fetching portfolio items: $e';
    } finally {
      portfolioSiteLoading(false);
    }
  }
    // Fetch user account data
  Future<void> fetchUserAccount({bool forceRefresh = false}) async {
    try {
      if (_authController.isDemo.value) {
        userAccount.assignAll(DemoData.account);
        accountError.value = '';
      //  _pushWidgetSummaryFromAccount();
        return;
      }
      final cacheKey = 'user_account';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<Map<String, dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 15),
        );
        if (cached != null) {
          userAccount.assignAll(cached);
          accountError.value = '';
          accountLoading.value = false;
          return;
        }
      }
      accountLoading.value = true;
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        accountError.value = 'Please sign in again.';
        return;
      }
      final account = await _apiService.getUserAccount();
      userAccount.value = account;
      await LocalCacheService.write(cacheKey, account);
    //  _pushWidgetSummaryFromAccount();
      accountError.value = '';
    } catch (e) {
      if (e is DioException) {
        print('User account error: status=${e.response?.statusCode}');
        print('User account response: ${e.response?.data}');
      } else {
        print('User account error: $e');
      }
      accountError.value = 'Error fetching user account data: $e';
    } finally {
      accountLoading.value = false;
    }
  }

  // void _pushWidgetSummaryFromAccount() {
  //   final balanceValue = userAccount['balance'];
  //   if (balanceValue == null) {
  //     return;
  //   }
  //   HomeWidgetService.updateSummary(balance: balanceValue.toString());
  // }

  // void _pushWidgetSummaryFromDetails() {
  //   final salesValue = userDetails['sales'];
  //   if (salesValue == null) {
  //     return;
  //   }
  //   final sales = int.tryParse(salesValue.toString());
  //   if (sales == null) {
  //     return;
  //   }
  //   HomeWidgetService.updateSummary(sales: sales);
  // }


}
