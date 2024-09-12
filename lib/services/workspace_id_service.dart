import 'dart:convert';
import 'package:haivanalytics/constants.dart';  // Import the constants file
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkspaceService {
  final String _apiUrl = 'https://app-haiva.gateway.apiplatform.io/v1/getAllWorkspacesByOrg';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<List<String>> getWorkspaces() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Ensure 'workspace' field exists and is a list
        if (data != null && data['workspace'] is List) {
          final List<String> workspaceIds = (data['workspace'] as List)
              .map((workspace) => workspace['workspace_id'] as String)
              .toList();

          // Store workspace IDs in secure storage
          await _secureStorage.write(key: 'workspace_ids', value: json.encode(workspaceIds));
          print('Stored workspace IDs: $workspaceIds');

          // Store the first workspace ID in the Constants file
          if (workspaceIds.isNotEmpty) {
            Constants.workspaceId = workspaceIds[0];
            print('First Workspace ID stored in Constants: ${Constants.workspaceId}');
          }

          return workspaceIds;
        } else {
          throw Exception('Unexpected response format: "workspace" field missing or not a list');
        }
      } else {
        throw Exception('Failed to load workspaces: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching workspaces: $e');
      rethrow;
    }
  }

  Future<List<String>> getStoredWorkspaceIds() async {
    final workspaceIds = await _secureStorage.read(key: 'workspace_ids');
    if (workspaceIds != null) {
      return List<String>.from(json.decode(workspaceIds));
    } else {
      return [];
    }
  }
}
