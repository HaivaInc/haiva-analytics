import 'package:flutter/material.dart';
import 'dart:math';

import '../services/agent_service.dart';


class ColorTheme with ChangeNotifier {
  // Static color properties
  static Color _primary = HexColor('#241c99'); // Initial primary color
  static Color _secondary = HexColor('#000000'); // Initial secondary color
  static Color _accent = HexColor('#000000'); // Initial accent color

  // Getters for static color properties
  static Color get primary => _primary;
  static Color get secondary => _secondary;
  static Color get accent => _accent;

  // Update color properties based on query parameters
  void updateColorsFromQueryParameters(Map<String, String> queryParams) {
    if (queryParams.containsKey('primary')) {
      _primary = HexColor(queryParams['primary']!);
    }
    if (queryParams.containsKey('secondary')) {
      _secondary = HexColor(queryParams['secondary']!);
    }
    if (queryParams.containsKey('accent')) {
      _accent = HexColor(queryParams['accent']!);
    }
    // Notify listeners to update the UI
    notifyListeners();
  }

  // Generate colors from agent configuration
  static Future<void> generateColorsFromAgent(String agentId) async {
    final agentService = AgentService();
    final agent = await agentService.getAgentById(agentId);

    if (agent!= null && agent.agentConfigs?.colors != null) {
      _primary = HexColor(agent.agentConfigs?.colors!['primary']);
      _secondary = HexColor(agent.agentConfigs?.colors!['secondary']);
      _accent = HexColor(agent.agentConfigs?.colors!['tertiary']);
    }
  }

  // Generate random colors
  static void generateRandomColors() {
    _primary = _generateRandomColor();
    _secondary = _generateComplementaryColor(_primary);
    _accent = _generateComplementaryColor(_primary);
  }

  // Helper methods
  static Color _generateRandomColor() {
    final random = Random();
    final hexColor = '#${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return HexColor(hexColor);
  }

  static Color _generateDarkerColor(Color baseColor, double amount) {
    final hsl = HSLColor.fromColor(baseColor);
    final darkenedHSL = hsl.withLightness((hsl.lightness * amount).clamp(0.0, 1.0));
    return darkenedHSL.toColor();
  }

  static Color _generateComplementaryColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return _generateDarkerColor(baseColor, 0.5);
  }
}

// HexColor class
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
