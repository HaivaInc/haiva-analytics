import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final WebviewCookieManager _cookieManager = WebviewCookieManager();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();


  final String _clientId = '3h3dhjghsivy3x3hegju3gijcj3ocr784grcHszP4KtyGnnZdARBXs';
  final String _domain = 'https://haiva.authent.works';
  final String _issuer = 'https://haiva.authent.works/auth';
  final String _redirectUri = 'com.haiva.auth:/callback';
  final String logoutUrl = 'https://haiva.authent.works/auth/logout';

  Future<bool> login() async {
    try {

      await _clearTokens();

      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUri,
          issuer: _issuer,
          scopes: ['openid', 'email', 'profile'],
        ),
      );

      if (result != null && result.accessToken != null) {
        // Store tokens securely
        await _secureStorage.write(key: 'access_token', value: result.accessToken);
        Constants.accessToken = result.accessToken;
        await _secureStorage.write(key: 'id_token', value: result.idToken);
        await _secureStorage.write(key: 'refresh_token', value: result.refreshToken);
        return true;
      } else {
        // Login was cancelled or failed
        await _clearTokens();
        return false;
      }
    } catch (e) {
      print('Login failed: $e');
      await _clearTokens();
      return false;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'id_token');
    await _secureStorage.delete(key: 'refresh_token');
    Constants.accessToken = null;
    Constants.workspaceId = null;
    Constants.orgId = null;
    Constants.defaultAgentId = null;
  }

  Future<bool> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken != null) {
        final Uri logoutUri = Uri.parse(logoutUrl);
        if (await canLaunchUrl(logoutUri)) {
          await launchUrl(logoutUri, mode: LaunchMode.inAppBrowserView);
        }
      }
      await _clearTokens();
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