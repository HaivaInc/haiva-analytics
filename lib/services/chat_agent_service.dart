import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_chat/agent_detail.dart';

class AgentChatService {
  final String _baseUrl = 'https://app-haiva.gateway.apiplatform.io/v1/getAgentConfig';

  Future<deployPayload?> getAgentById(String agentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?agent-id=$agentId'),
        // headers: {
        //   'Authorization': authorizationToken,
        // },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        //print('Raw JSON response: $json');
        return deployPayload.fromJson(json);
      }  else {
        throw Exception('Failed to load agent details');
      }
    } catch (e) {
      print('Exception while fetching agent details: $e');
      return null;
    }
  }
}
