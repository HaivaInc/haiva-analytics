import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/zoho_service.dart';

class ConfigurationProvider with ChangeNotifier {
  String _connectorName = '';
  String _authType = 'OAuth2.0';
  String _token = '';
  String _authorizeUrl = '';
  String _accessTokenUrl = '';
  String _refreshTokenUrl = '';
  String _clientId = '';
  String _clientSecret = '';
  String _scope = '';

  String get authType => _authType;
  String get connectorName => _connectorName;
  String get token => _token;
  String get authorizeUrl => _authorizeUrl;
  String get accessTokenUrl => _accessTokenUrl;
  String get refreshTokenUrl => _refreshTokenUrl;
  String get clientId => _clientId;
  String get clientSecret => _clientSecret;
  String get scope => _scope;

  void setAuthType(String value) {
    _authType = value;
    notifyListeners();
  }

  void setConnectorName(String value) {
    _connectorName = value;
    notifyListeners();
  }

  void setToken(String value) {
    _token = value;
    notifyListeners();
  }

  void setAuthorizeUrl(String value) {
    _authorizeUrl = value;
    notifyListeners();
  }

  void setAccessTokenUrl(String value) {
    _accessTokenUrl = value;
    notifyListeners();
  }

  void setRefreshTokenUrl(String value) {
    _refreshTokenUrl = value;
    notifyListeners();
  }

  void setClientId(String value) {
    _clientId = value;
    notifyListeners();
  }

  void setClientSecret(String value) {
    _clientSecret = value;
    notifyListeners();
  }

  void setScope(String value) {
    _scope = value;
    notifyListeners();
  }

  Future<(bool, String)> configure() async {
    try {
      Map<String, dynamic> payload = {
        'connectorName': _connectorName,
        'authType': _authType,
      };

      if (_authType == 'Bearer Token') {
        payload['token'] = _token;
      } else {
        payload.addAll({
          'authorizeUrl': _authorizeUrl,
          'accessTokenUrl': _accessTokenUrl,
          'refreshTokenUrl': _refreshTokenUrl,
          'clientId': _clientId,
          'clientSecret': _clientSecret,
          'scope': _scope,
        });
      }

      bool result = await ApiService.configureInventory(payload);
      if (result) {
        return (true, 'Configuration successful');
      } else {
        return (false, 'Configuration failed');
      }
    } catch (e) {
      return (false, 'Configuration failed: $e');
    }
  }
}