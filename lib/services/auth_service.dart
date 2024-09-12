import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haivanalytics/services/zoho_service.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final String _clientId = '3h3dhjghsivy3x3hegju3gijcj3ocr784grcHszP4KtyGnnZdARBXs';
  final String _issuer = 'https://haiva.authent.works/auth';
  final String _redirectUri = 'com.haiva.auth:/callback';
  final String _logoutUrl = 'https://haiva.authent.works/auth/logout';

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
      await _secureStorage.deleteAll();
      isAuthenticated() == false;
      _appAuth.endSession(

        EndSessionRequest()
      );
      // Optionally reset the access token in Constants
      Constants.accessToken = null;
      return true; // Indicate successful logout
    } catch (e) {
      print('Logout failed: $e');
      return false; // Indicate failure
    }
  }


  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    Constants.accessToken = accessToken;
    return accessToken != null;
  }
}
