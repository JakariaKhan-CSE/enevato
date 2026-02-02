
import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:myenvato/network/api_service.dart';
import 'package:myenvato/services/local_cache_service.dart';

class AuthController extends GetxController {
  AuthController({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final String clientId = 'evacado-tracker-ypitqhbg';
  final String clientSecret = 'Joih9Cny9NCOgR9VRQllZRQ9gSdp5CqR';
  final String redirectUri = 'https://evacado-web.web.app/envato/callback';
  final String authEndpoint = 'https://api.envato.com/authorization';
  final String _prefsTokenKey = 'envato_access_token';
  final String _prefsRefreshTokenKey = 'envato_refresh_token';
  final String _prefsTokenExpiryKey = 'envato_token_expiry';
  final String _prefsDemoKey = 'demo_mode';

  RxString accessToken = ''.obs;
  RxString refreshToken = ''.obs;
  Rxn<DateTime> tokenExpiry = Rxn<DateTime>();
  RxBool isBusy = false.obs;
  RxString errorMessage = ''.obs;
  Rxn<Map<String, dynamic>> userAccount = Rxn<Map<String, dynamic>>();
  RxBool isDemo = false.obs;
  late final Future<void> _initFuture;

  @override
  void onInit() {
    super.onInit();
    _initFuture = Future.wait([
      _loadSavedToken(),
      _loadDemoFlag(),
    ]);
  }

  Future<void> waitForReady() => _initFuture;

  void _notify(String title, String message) {
    errorMessage.value = message;
    final overlay = Get.key.currentState?.overlay;
    if (overlay == null || Get.overlayContext == null) {
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final overlayAfterFrame = Get.key.currentState?.overlay;
      if (overlayAfterFrame == null || Get.overlayContext == null) {
        return;
      }
      try {
        Get.snackbar(title, message);
      } catch (_) {
        // Ignore snackbar failures when no overlay is available.
      }
    });
  }

  int? _parseExpiresIn(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Future<void> _loadSavedToken() async {
    print('AuthController: loading saved token');
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_prefsTokenKey) ?? '';
    final savedRefresh = prefs.getString(_prefsRefreshTokenKey) ?? '';
    final savedExpiryMillis = prefs.getInt(_prefsTokenExpiryKey);
    if (savedToken.isEmpty) {
      print('AuthController: no saved token');
      return;
    }
    print('AuthController: saved token found, refresh=${savedRefresh.isNotEmpty}, expiry=$savedExpiryMillis');
    accessToken.value = savedToken;
    refreshToken.value = savedRefresh;
    if (savedExpiryMillis != null) {
      tokenExpiry.value = DateTime.fromMillisecondsSinceEpoch(savedExpiryMillis);
    }
    _apiService.setAccessToken(savedToken);
    final isValid = await ensureValidToken();
    if (!isValid) {
      print('AuthController: saved token invalid');
      return;
    }
    print('AuthController: saved token valid, fetching account');
    await fetchUserAccount();
  }

  Future<void> _loadDemoFlag() async {
    final prefs = await SharedPreferences.getInstance();
    isDemo.value = prefs.getBool(_prefsDemoKey) ?? false;
  }

  Future<void> enableDemo() async {
    await signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsDemoKey, true);
    isDemo.value = true;
  }

  Future<void> disableDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsDemoKey, false);
    isDemo.value = false;
  }

  Uri _buildAuthUri() {
    return Uri.parse(authEndpoint).replace(
      queryParameters: <String, String>{
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
      },
    );
  }

  Future<void> initiateLogin() async {
    try {
      errorMessage.value = '';
      await disableDemo();
      print('AuthController: starting login flow');
      final result = await FlutterWebAuth2.authenticate(
        url: _buildAuthUri().toString(),
        callbackUrlScheme: 'evacado-tracker',
      );

      final Uri resultUri = Uri.parse(result);
      if (resultUri.queryParameters.containsKey('code')) {
        final code = resultUri.queryParameters['code'];
        print('AuthController: auth code received');
        await fetchAccessToken(code!);
      } else {
        _notify('Error', 'Authorization code not received.');
      }
    } catch (e) {
      print('AuthController: login error $e');
      _notify('Error', 'Authentication failed: $e');
    }
  }

  Future<void> fetchAccessToken(String code) async {
    isBusy.value = true;
    const url = 'https://api.envato.com/token';
    final body = {
      'grant_type': 'authorization_code',
      'code': code,
      'client_id': clientId,
      'client_secret': clientSecret,
      'redirect_uri': redirectUri,
    };

    try {
      print('AuthController: exchanging auth code for token');
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String?;
        final refresh = data['refresh_token'] as String?;
        final expiresIn = _parseExpiresIn(data['expires_in']);
        if (token == null || token.isEmpty) {
          throw Exception('Access token missing from response.');
        }
        print('AuthController: token received, refresh=${refresh != null && refresh.isNotEmpty}, expiresIn=$expiresIn');
        accessToken.value = token;
        if (refresh != null && refresh.isNotEmpty) {
          refreshToken.value = refresh;
        }
        if (expiresIn != null) {
          tokenExpiry.value = DateTime.now().add(Duration(seconds: expiresIn - 30));
        }
        _apiService.setAccessToken(token);
        await _persistTokens();
        await fetchUserAccount();
        _notify('Success', 'Signed in successfully');
      } else {
        print('AuthController: token exchange failed status=${response.statusCode} body=${response.body}');
        _notify('Error', 'Failed to fetch access token.');
      }
    } catch (e) {
      print('AuthController: token exchange error $e');
      _notify('Error', 'Something went wrong: $e');
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> ensureValidToken() async {
    final expiry = tokenExpiry.value;
    if (accessToken.value.isEmpty) {
      print('AuthController: no access token');
      return false;
    }
    print('AuthController: token present, expiry=$expiry');
    _apiService.setAccessToken(accessToken.value);
    if (expiry == null || DateTime.now().isBefore(expiry)) {
      print('AuthController: token valid (not expired)');
      return true;
    }
    if (refreshToken.value.isEmpty) {
      print('AuthController: token expired and no refresh token');
      await signOut();
      _notify('Session expired', 'Please sign in again.');
      return false;
    }
    print('AuthController: token expired, refreshing');
    final refreshed = await refreshAccessToken();
    if (!refreshed) {
      print('AuthController: token refresh failed');
      await signOut();
      _notify('Session expired', 'Please sign in again.');
      return false;
    }
    print('AuthController: token refreshed');
    return true;
  }

  Future<bool> refreshAccessToken() async {
    isBusy.value = true;
    final url = 'https://api.envato.com/token';
    final body = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken.value,
      'client_id': clientId,
      'client_secret': clientSecret,
    };

    try {
      print('AuthController: refreshing token');
      final response = await http.post(Uri.parse(url), body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String?;
        final expiresIn = _parseExpiresIn(data['expires_in']);
        if (token == null || token.isEmpty) {
          throw Exception('Access token missing from refresh response.');
        }
        print('AuthController: refresh success expiresIn=$expiresIn');
        accessToken.value = token;
        if (expiresIn != null) {
          tokenExpiry.value = DateTime.now().add(Duration(seconds: expiresIn - 30));
        }
        _apiService.setAccessToken(token);
        await _persistTokens();
        return true;
      } else {
        print('AuthController: refresh failed status=${response.statusCode} body=${response.body}');
        _notify('Error', 'Failed to refresh access token.');
        return false;
      }
    } catch (e) {
      print('AuthController: refresh error $e');
      _notify('Error', 'Failed to refresh access token: $e');
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> fetchUserAccount({bool forceRefresh = false}) async {
    final isValid = await ensureValidToken();
    if (!isValid) {
      return;
    }
    if (accessToken.value.isEmpty) {
      return;
    }
    isBusy.value = true;
    try {
      if (!forceRefresh) {
        final cached = LocalCacheService.read<Map<String, dynamic>>(
          'user_account',
          maxAge: const Duration(minutes: 15),
        );
        if (cached != null) {
          userAccount.value = cached;
          return;
        }
      }
      final account = await _apiService.getUserAccount();
      userAccount.value = account;
      await LocalCacheService.write('user_account', account);
    } catch (e) {
      _notify('Error', 'Failed to load account data: $e');
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _persistTokens() async {
    final prefs = await SharedPreferences.getInstance();
    print('AuthController: persisting tokens');
    await prefs.setString(_prefsTokenKey, accessToken.value);
    if (refreshToken.value.isNotEmpty) {
      await prefs.setString(_prefsRefreshTokenKey, refreshToken.value);
    }
    final expiry = tokenExpiry.value;
    if (expiry != null) {
      await prefs.setInt(_prefsTokenExpiryKey, expiry.millisecondsSinceEpoch);
    }
  }

  Future<void> signOut() async {
    accessToken.value = '';
    refreshToken.value = '';
    tokenExpiry.value = null;
    userAccount.value = null;
    _apiService.setAccessToken(null);
    await LocalCacheService.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsTokenKey);
    await prefs.remove(_prefsRefreshTokenKey);
    await prefs.remove(_prefsTokenExpiryKey);
  }
}
