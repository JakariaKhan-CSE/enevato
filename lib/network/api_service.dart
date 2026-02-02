import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final Dio _dio;

  factory ApiService({String? accessToken}) {
    if (accessToken != null && accessToken.isNotEmpty) {
      _instance.setAccessToken(accessToken);
    }
    return _instance;
  }

  ApiService._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.envato.com',
          ),
        ) {
    // Adding Dio cache interceptor
    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.request,
      hitCacheOnErrorExcept: [401, 403], // Handle caching for error codes
      maxStale: const Duration(days: 7),
    );
    _dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  void setAccessToken(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) {
      print('ApiService: clearing access token');
      _dio.options.headers.remove('Authorization');
      return;
    }
    print('ApiService: setting access token');
    _dio.options.headers['Authorization'] = 'Bearer $accessToken';
  }

  Future<int> getTotalUsers() async {
    try {
      final response = await _dio.get('/v1/market/total-users.json');
      if (response.statusCode == 200) {
        return int.parse(response.data['total-users']['total_users']);
      }
      throw Exception('Failed to load total users');
    } catch (e) {
      print('Error fetching total users: $e');
      rethrow;
    }
  }
  
  Future<int> getTotalItems() async {
    try {
      final response = await _dio.get('/v1/market/total-items.json');
      if (response.statusCode == 200) {
        return int.parse(response.data['total-items']['total_items']);
      }
      throw Exception('Failed to load total items');
    } catch (e) {
      print('Error fetching total items: $e');
      rethrow;
    }
  }

// Fetch number of files in different categories
  Future<List<dynamic>> getNumberOfFiles(String site) async {
    final String url = '/v1/market/number-of-files:$site.json';
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data['number-of-files'] as List<dynamic>;
      } else {
        throw Exception('Failed to load number of files');
      }
    } catch (e) {
      print('Error fetching number of files: $e');
      rethrow;
    }
  }


  // Fetch user's statement
  Future<List<dynamic>> getUserStatement({
    required int page,
    String? fromDate,
    String? toDate,
    String? type,
    String? site,
  }) async {
    try {
      final response = await _dio.get(
        '/v3/market/user/statement',
        queryParameters: {
          'page': page,
          if (fromDate != null) 'from_date': fromDate,
          if (toDate != null) 'to_date': toDate,
          if (type != null) 'type': type,
          if (site != null) 'site': site,
        },
      );

      if (response.statusCode == 200) {
        return response.data['results']; // Return statement lines
      } else {
        throw Exception('Failed to load user statement');
      }
    } catch (e) {
      print('Error fetching user statement: $e');
      rethrow;
    }
  }
  // Fetch user account details
  Future<Map<String, dynamic>> getUserAccount() async {
    try {
      final response = await _dio.get('/v1/market/private/user/account.json');
      if (response.statusCode == 200 ||
          (response.statusCode == 304 && response.data != null)) {
        return response.data['account'];
      } else {
        print(
            'ApiService: user account status=${response.statusCode} body=${response.data}');
        throw Exception('Failed to load user account data');
      }
    } catch (e) {
      print('Error fetching user account data: $e');
      rethrow;
    }
  }


  // Fetch user details by username
  Future<Map<String, dynamic>> getUserDetails(String username) async {
    final String url = '/v1/market/user:$username.json';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200 ||
          (response.statusCode == 304 && response.data != null)) {
        return response.data['user'] as Map<String, dynamic>;
      } else {
        print(
            'ApiService: user details status=${response.statusCode} body=${response.data}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      rethrow;
    }
  }

  //user badge

  Future<List<dynamic>> getUserBadges(String username) async {
    final String url = '/v1/market/user-badges:$username.json';
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200 ||
          (response.statusCode == 304 && response.data != null)) {
        return response.data['user-badges'] as List<dynamic>;
      } else {
        print(
            'ApiService: user badges status=${response.statusCode} body=${response.data}');
        throw Exception('Failed to load user badges');
      }
    } catch (e) {
      print('Error fetching user badges: $e');
      rethrow;
    }
  }

  // Fetch user items by site
  Future<List<dynamic>> getUserItemsBySite(String username) async {
    try {
      final response = await _dio.get('/v1/market/user-items-by-site:$username.json');
      if (response.statusCode == 200) {
        return response.data['user-items-by-site'] as List<dynamic>;
      } else {
        throw Exception('Failed to load user items by site');
      }
    } catch (e) {
      print('Error fetching user items by site: $e');
      rethrow;
    }
  }

  // Fetch user portfolio items
  Future<List<dynamic>> getUserItems(String username) async {
    try {
      final response = await _dio.get('/v1/market/user-items:$username.json');
      if (response.statusCode == 200) {
        return response.data['user-items'] as List<dynamic>;
      } else {
        throw Exception('Failed to load user items');
      }
    } catch (e) {
      print('Error fetching user items: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getNewFilesFromUser({
    required String username,
    required String site,
  }) async {
    final path = '/v1/market/new-files-from-user:$username,$site.json';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200 ||
          (response.statusCode == 304 && response.data != null)) {
        return response.data['new-files-from-user'] as List<dynamic>;
      }
      print('ApiService: new files status=${response.statusCode} body=${response.data}');
      throw Exception('Failed to load new files');
    } catch (e) {
      print('Error fetching new files: $e');
      rethrow;
    }
  }


  // Fetch earnings and sales by month
  Future<List<Map<String, dynamic>>> getEarningsAndSalesByMonth() async {
    try {
      final response = await _dio.get('/v1/market/private/user/earnings-and-sales-by-month.json');
      if (response.statusCode == 200 ||
          (response.statusCode == 304 && response.data != null)) {
        return (response.data['earnings-and-sales-by-month'] as List)
            .map((item) => {
                  'month': item['month'],
                  'sales': int.parse(item['sales']),
                  'earnings': double.parse(item['earnings']),
                })
            .toList();
      } else {
        print(
            'ApiService: earnings status=${response.statusCode} body=${response.data}');
        throw Exception('Failed to load earnings and sales data');
      }
    } catch (e) {
      print('Error fetching earnings and sales data: $e');
      rethrow;
    }
  }



}
