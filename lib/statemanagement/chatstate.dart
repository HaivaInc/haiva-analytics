import 'package:flutter/material.dart';

import '../model_chat/agent_detail.dart';
import '../services/chat_agent_service.dart';

class ChatProvider with ChangeNotifier {
  bool _isAgentScreen = true;

  bool get isAgentScreen => _isAgentScreen;
  String _agentId = '';

  String get agentId => _agentId;
  AgentConfigs? _agentDetails;

  AgentConfigs? get agentDetails => _agentDetails;
  bool? _isDeployed;
  bool? get isDeployed => _isDeployed;
  final AgentChatService _agentService = AgentChatService();



  void setAgentId(String agentId) {
    _agentId = agentId;
    notifyListeners();
  }

  void toggleChatScreen() {
    _isAgentScreen = !_isAgentScreen;
    notifyListeners();
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAgentDetails() async {
    try {
      final agent = await _agentService.getAgentById(_agentId);
      if (agent != null) {
        _agentDetails = agent.agentConfigs;
        _isDeployed = agent.isDeployed; // Set the deployment status

        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to fetch agent details.';
      }
    } catch (e) {
      _errorMessage = 'Exception while fetching agent details: $e';
    }
    notifyListeners();
  }



}
