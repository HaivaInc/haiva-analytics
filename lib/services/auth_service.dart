import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:haivanalytics/services/zoho_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants.dart';
import '../pages/onboard.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final WebviewCookieManager _cookieManager = WebviewCookieManager();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final String _clientId = '3h3dhjghsivy3x3hegju3gijcj3ocr784grcHszP4KtyGnnZdARBXs';
  final String _domain = 'https://haiva.authent.works';
  final String _issuer = 'https://haiva.authent.works/auth';
  final String _redirectUri = 'com.haiva.auth:/callback';
  final String logoutUrl = 'https://haiva.authent.works/auth/logout';

  Future<void> login() async {
    try {
      final AuthorizationTokenResponse? result = await _appAuth
          .authorizeAndExchangeCode(
        AuthorizationTokenRequest(

          _clientId,
          _redirectUri,
          issuer: _issuer,

          scopes: ['openid', 'email', 'profile'],
        ),
      );

      // Store tokens securely
      await _secureStorage.write(
          key: 'access_token', value: result?.accessToken);
      Constants.accessToken = result?.accessToken;
      await _secureStorage.write(key: 'id_token', value: result?.idToken);
      await _secureStorage.write(
          key: 'refresh_token', value: result?.refreshToken);
    } catch (e) {
      print('Login failed: $e');
    }
  }
  Future<bool> logout() async {
    try {

      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken != null) {
        print(Constants.accessToken);


          final Uri logoutUri = Uri.parse(logoutUrl);

          // Handle for mobile and web
          if (await canLaunchUrl(logoutUri)) {
         await launchUrl(
              logoutUri,
              mode: LaunchMode.inAppBrowserView, // Ensure external logout
            );
          }
      }

      await _secureStorage.deleteAll();
      Constants.accessToken = null;
      Constants.workspaceId = null;
      Constants.orgId = null;
await _cookieManager.getCookies(_domain);
print("cookies ${await _cookieManager.getCookies(_domain)}");
      await _cookieManager.removeCookie(_domain);

      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }


  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    Constants.accessToken = accessToken;
    return accessToken != null;
  }
}
