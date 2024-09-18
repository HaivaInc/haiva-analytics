import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/agent.dart';

class DbService {
  static const String baseUrl1 = 'https://app-haiva.gateway.apiplatform.io/v1';
  static const String baseUrl = 'https://app-haiva.gateway.apiplatform.io/v2';
  static  String? workspaceId = Constants.workspaceId;
  static  String? orgId = Constants.orgId;

  static  String? token = Constants.accessToken;
  // Insert Database Connection Info
  Future<http.Response> insertDatabaseConnection({
    required String dbName,
    required String host,
    required String password,
    required String port,
    required String username,
    required String databaseName,
    required String databaseType,
    bool isNoSql = false,
    bool isEncrypt = false,
  }) async {
    final url = Uri.parse('$baseUrl/insertDatabaseConnectionInfo?workspaceId=$workspaceId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "database_attributes": {
        "dbName": dbName,
        "host": host,
        "password": password,
        "port": port,
        "username": username
      },
      "database_name": databaseName,
      "database_type": databaseType,
      "is_nosql": isNoSql,
      "is_encrypt": isEncrypt
    });

    print("Request Body = $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Failed to insert database connection');
    }
  }
  // Get Database Connection Info
  Future<http.Response> getDatabaseConnection() async {
    final url = Uri.parse('$baseUrl1/getDatabaseConnectionInfo?workspaceId=$workspaceId&to_decrypt=true');

    return await http.get(url);
  }

  Future<http.Response> getDatabaseTables(String databaseName) async {

    final url = 'https://apiservices.haiva.ai/v1/admin/$orgId/$workspaceId/$databaseName/get-database-tables';

    print("url = $url");

    try {
      final response = await http.get(Uri.parse(url));
      return response;
    } catch (e) {
      throw Exception('Failed to get database tables: ${e.toString()}');
    }
  }

  // Modify Database Connection Info
  Future<http.Response> modifyDatabaseConnection({
    required String databaseName,
    required String dbName,
    required String host,
    required String password,
    required String port,
    required String username,
  }) async {
    final url = Uri.parse('$baseUrl/modifyDatabaseConnection?workspaceId=$workspaceId&databaseName=$databaseName&is_encrypt=true');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "database_attributes": {
        "dbName": dbName,
        "host": host,
        "password": password,
        "port": port,
        "username": username
      }
    });

    return await http.patch(url, headers: headers, body: body);
  }

  Future<http.Response> saveDbConfig(String agentId,Map<String, dynamic> dbConfig) async {
    final url = Uri.parse('$baseUrl1/saveHaivaAgentConfig?agent-id=${agentId}');
    print("agentid = ${agentId}");
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(dbConfig),
    );

    if (response.statusCode == 200  || response.statusCode == 201) {
      print('db saved successfully');
      return response;

    } else {
      // Handle error
      throw Exception('Failed to update agent${response.body}');
    }
  }



}
