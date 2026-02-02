import 'package:get/get.dart';
import 'package:myenvato/controller/user/auth_controller.dart';
import 'package:myenvato/demo/demo_data.dart';
import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/local_cache_service.dart';
import 'package:intl/intl.dart';

class StatementController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController _authController = Get.find<AuthController>();
  late final Worker _authWorker;

  var userStatement = <dynamic>[].obs; // Observable list for statement lines
  var isLoading = false.obs;
  var selectedDateRange = 'Last 30 Days'.obs; // Default selected date range
  var errorMessage = ''.obs;
  var allStatements = <dynamic>[].obs;
  var allStatementsLoading = false.obs;
  var allStatementsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _authController.waitForReady().then((_) {
      if (_authController.isDemo.value ||
          _authController.accessToken.isNotEmpty) {
        fetchUserStatement();
      }
    });
    _authWorker = ever<String>(_authController.accessToken, (token) {
      if (token.isEmpty) {
        if (_authController.isDemo.value) {
          fetchUserStatement();
        }
        return;
      }
      fetchUserStatement();
    });
  }

  @override
  void onClose() {
    _authWorker.dispose();
    super.onClose();
  }

  // Fetch user statement with optional filters
  Future<void> fetchUserStatement({
    int page = 1,
    String? fromDate,
    String? toDate,
    String? type,
    String? site,
    bool forceRefresh = false,
  }) async {
    isLoading.value = true; // Set loading to true before API call
    try {
      if (_authController.isDemo.value) {
        userStatement.value = DemoData.statementLines;
        errorMessage.value = '';
        return;
      }
      final cacheKey = 'statement:$page:${fromDate ?? ''}:${toDate ?? ''}:${type ?? ''}:${site ?? ''}';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 5),
        );
        if (cached != null) {
          userStatement.value = cached;
          errorMessage.value = '';
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        return;
      }
      final statement = await apiService.getUserStatement(
        page: page,
        fromDate: fromDate,
        toDate: toDate,
        type: type,
        site: site,
      );
      userStatement.value = statement;
      await LocalCacheService.write(cacheKey, statement);
      errorMessage.value = '';
    } catch (e) {
      // Handle error properly here
      print('Error fetching user statement: $e');
      errorMessage.value = 'Error fetching user statement: $e';
    } finally {
      isLoading.value = false; // Set loading to false after API call
    }
  }

  Future<void> fetchAllStatements({int maxPages = 20, bool forceRefresh = false}) async {
    allStatementsLoading.value = true;
    try {
      if (_authController.isDemo.value) {
        allStatements.value = DemoData.statementLines;
        allStatementsError.value = '';
        return;
      }
      final cacheKey = 'statements_all:$maxPages';
      if (!forceRefresh) {
        final cached = LocalCacheService.read<List<dynamic>>(
          cacheKey,
          maxAge: const Duration(minutes: 10),
        );
        if (cached != null) {
          allStatements.value = cached;
          allStatementsError.value = '';
          return;
        }
      }
      final isValid = await _authController.ensureValidToken();
      if (!isValid) {
        allStatementsError.value = 'Please sign in again.';
        return;
      }
      final List<dynamic> combined = [];
      for (var page = 1; page <= maxPages; page++) {
        final pageItems = await apiService.getUserStatement(page: page);
        if (pageItems.isEmpty) {
          break;
        }
        combined.addAll(pageItems);
      }
      allStatements.value = combined;
      await LocalCacheService.write(cacheKey, combined);
      allStatementsError.value = '';
    } catch (e) {
      print('Error fetching all statements: $e');
      allStatementsError.value = 'Error fetching statements: $e';
    } finally {
      allStatementsLoading.value = false;
    }
  }

  // Handle date range selection
  void onDateRangeSelected(String value) {
    DateTime now = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    String? fromDate;
    String? toDate;

    if (value == 'last_30_days') {
      // Last 30 days
      fromDate = dateFormat.format(now.subtract(const Duration(days: 30)));
      toDate = dateFormat.format(now);
      selectedDateRange.value = 'Last 30 Days';
    } else if (value == 'current_month') {
      // Current month
      fromDate = dateFormat.format(DateTime(now.year, now.month, 1));
      toDate = dateFormat.format(now);
      selectedDateRange.value = DateFormat('MMMM yyyy').format(now);
    } else if (value == 'last_2_months') {
      // Last 2 months
      DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
      fromDate = dateFormat.format(lastMonth);
      toDate = dateFormat.format(now);
      selectedDateRange.value = 'Last 2 Months';
    }

    // Fetch statement with the selected date range
    fetchUserStatement(fromDate: fromDate, toDate: toDate);
  }
}
