import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/workspace_provider.dart';

class ApiService {
  static const String apiUrl = 'https://app-haiva.gateway.apiplatform.io/v1/insertApiConnectorInfo';
  static final WorkspaceProvider _workspaceProvider = WorkspaceProvider();
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String?> get workspaceId async {
    if (_workspaceProvider.workspaces.isNotEmpty) {
      return _workspaceProvider.workspaces[0];
    }
    return null;
  }

  static Future<String?> get authToken async {
    return await _secureStorage.read(key: 'access_token');
  }

  static Future<bool> configureInventory(Map<String, dynamic> payload) async {
    try {
      final String? currentWorkspaceId = await workspaceId;
      final String? currentAuthToken = await authToken;

      if (currentWorkspaceId == null || currentAuthToken == null) {
        print('WorkspaceId or AuthToken is null');
        return false;
      }

      final List<Map<String, String>> formattedCredentials = payload.entries.map((entry) {
        return {
          "key": entry.key,
          "value": entry.value.toString(),
        };
      }).toList();

      final Map<String, dynamic> data = {
        "name": payload['connectorName'],
        "credentials": formattedCredentials,
        "status": false,
        "authType": payload['authType'],
        "producer": "prod"
      };

      final response = await http.post(
        Uri.parse('$apiUrl?workspaceId=$currentWorkspaceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentAuthToken',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Configuration successful');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isConfigured', true);
        return true;
      } else {
        print('Configuration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }

  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isConfigured') ?? false;
  }
}