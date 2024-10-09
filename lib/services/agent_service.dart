import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../constants.dart';
import '../models/agent.dart';

class AgentService {
  final String baseUrl = 'https://app-haiva.gateway.apiplatform.io/v1';
  final String baseUrl2 = 'https://app-haiva.gateway.apiplatform.io/v2';
  static  String? workspaceId = Constants.workspaceId;
  static  String? token = Constants.accessToken;

  Future<Agent> getAgentById(String agentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getHaivaAgentConfig?agent-id=$agentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      Constants.orgId = data['org_id'];
      print("orgid = ${Constants.orgId}");
      return Agent.fromJson(data);
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load agent with ID: $agentId');
    }
  }

  Future<List<Agent>> getAgents() async {

    final response = await http.get(
      Uri.parse('$baseUrl2/getAllHaivaAgentsByWs?agentType=Analytics&workspace-id=$workspaceId'),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);

      final List<dynamic> agentsJson = data['agent'];
      Constants.orgId = agentsJson[0]['org_id'];
      print("org id :${agentsJson[0]['org_id']}");
      return agentsJson.map((json) => Agent.fromJson(json)).toList();
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load agents');
    }}


  Future<String> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/insertAvatar'),
    )
      ..headers['Authorization'] = 'Bearer ${Constants.accessToken}' // Add the authorization header
      ..fields['workspaceId'] = Constants.workspaceId! // Add the workspaceId field
      ..files.add(
        http.MultipartFile.fromBytes(
          'avatarFile',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
          contentType: MediaType.parse(lookupMimeType(image.path) ?? 'application/octet-stream'),
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);
      if (data['Url'] != null && data['Url'] is String) {
        print('Url: ${data['Url']}');
        return data['Url'] as String;
      } else {
        throw Exception('Invalid response format: Url is missing or not a string');
      }
    } else {
      final responseData = await response.stream.bytesToString();
      final errorMessage = json.decode(responseData)['message'] ?? 'Failed to upload image';
      throw Exception(errorMessage);
    }
  }


  Future<String> createAgent(Agent agent) async {
    final response = await http.post(
      Uri.parse('$baseUrl/insertHaivaAgentInfo?workspace-id=$workspaceId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': agent.name,
        'description': agent.description,
        'type': agent.type,
        'image': agent.agentConfigs?.image,
        'display_name': agent.agentConfigs?.displayName,
        'colors': agent.agentConfigs?.colors ?? {},
      }),
    );


    if (response.statusCode == 200 || response.statusCode == 201) {

      final Map<String, dynamic> data = json.decode(response.body);
      return data['agentId'];
    } else {
      throw Exception('Failed to create agent');
    }
  }

  Future<void> updateAgent(Agent agent) async {
    final url = Uri.parse('$baseUrl/saveHaivaAgentConfig?agent-id=${agent.id}');
print("agentid = ${agent.id}");
    final response = await http.post(
      url,
      headers: {
         'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
       },
      body: json.encode({
        // 'name': agent.name,
        // 'description': agent.description,
        // 'type': agent.type,
        // 'agent_id': agent.id,
        'agent_configs': {
          'image': agent.agentConfigs?.image,
          'display_name': agent.agentConfigs?.displayName,
          'is_speech2text': agent.agentConfigs?.isSpeech2text,
          'languages': agent.agentConfigs?.languages,
          'colors': agent.agentConfigs?.colors ?? {},
          'description': agent.agentConfigs?.description
        },
       // 'is_deployed': agent.isDeployed,
       // 'is_active': agent.isActive,
       // 'updated_at': DateTime.now().toUtc().toIso8601String(),
        //'workspace_id': agent.workspaceId,
      //  'org_id': agent.orgId,
      }),
    );
print("response = ${response.body}");
print("response = ${response.statusCode}");
    if (response.statusCode == 200  || response.statusCode == 201) {
      print('Agent updated successfully');
    } else {
      // Handle error
      throw Exception('Failed to update agent${response.body}');
    }
  }

  Future<void> deleteAgent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteHaivaAgent?agentId=$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      print('Agent deleted successfully');
    } else {
      // Handle error
      throw Exception('Failed to delete agent');
    }
  }

  Future<http.Response> publishAgent(String agentID) async {
    final uri = Uri.parse(
        'https://app-haiva.gateway.apiplatform.io/v1/publishAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      if (response.statusCode == 200) {
        print('Agent published successfully: $agentID');
      } else {
        print('Failed to publish agent: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      print('Error publishing agent: $e');
      rethrow;
    }
  }
  Future<http.Response> featureAgent(String agentID) async {
    final uri = Uri.parse(
        'https://app-haiva.gateway.apiplatform.io/v1/featureAgent?agentId=$agentID');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: '{}',
      );
      if (response.statusCode == 200) {
        print('Agent published successfully: $agentID');
      } else {
        print('Failed to publish agent: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      print('Error publishing agent: $e');
      rethrow;
    }
  }
}
