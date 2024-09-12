import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants.dart';

class DeployService {
  final String baseUrl = 'https://app-haiva.gateway.apiplatform.io/v2';
  final String? authToken = Constants.accessToken;
  Future<http.Response> deployHaivaAgent(String agentId) async {
    final url = Uri.parse('$baseUrl/deployHaivaAgent').replace(
      queryParameters: {
        'workspace-id': Constants.workspaceId,
        'agent-id': agentId,
      },
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': authToken!,
          'Content-Type': 'application/json',
        },
        // Add request body here if needed
        body: json.encode({
          // Add any required body parameters
        }),
      );

      if (response.statusCode == 200) {
        print('HAIVA Agent deployed successfully');
        return response;
      } else {
        print('Failed to deploy HAIVA Agent. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to deploy HAIVA Agent');
      }
    } catch (e) {
      print('Error deploying HAIVA Agent: $e');
      throw Exception('Error deploying HAIVA Agent: $e');
    }
  }


  Future<http.Response> deployHaivaDb(String agentId, Map<String, dynamic> dbConfig) async {
    final url = Uri.parse('$baseUrl/deployHaivaAgent').replace(
      queryParameters: {
        'workspace-id': Constants.workspaceId,
        'agent-id': agentId,
      },
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': authToken!,
          'Content-Type': 'application/json',
        },

        body: json.encode(dbConfig),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('HAIVA Agent deployed successfully');
        print('Response body: ${response.body}');
        return response;
      } else {
        print('Failed to deploy HAIVA Agent. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to deploy HAIVA Agent');
      }
    } catch (e) {
      print(json.encode(dbConfig));
      print('Error deploying HAIVA Agent: $e');
      throw Exception('Error deploying HAIVA Agent: $e');
    }
  }
}