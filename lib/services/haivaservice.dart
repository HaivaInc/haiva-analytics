import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../model_chat/responsemsg.dart';

final String _haivaUrl = haivaProd;

class HaivaService {
  String? _sessionId;
  Future<ResponseMessage> haivaMessage(
      String question,
      String agentId, {
        bool? isMarkdown,
        bool? isButtonClicked,
        String payloadType = 'form',
        Map<String, dynamic>? formData,
        String? sessionId,
        String? language,
      }) async {


    Map<String, dynamic> userPayload;
    if (payloadType == 'text') {
      userPayload = {
        "type": payloadType,
        "data": {
          "message": question,
          "isButtonClicked": isButtonClicked,
        }
      };
    } else if (payloadType == 'form') {

      userPayload = {
        "type": payloadType,
        "data": {"formAttributes":formData ?? {}}, // Ensure formData is not null
      };
    } else {
      throw Exception('Invalid payload type');
    }

    // print('Payload to be sent: $userPayload'); // Print the final payload

    final response = await http.post(
      Uri.parse(_haivaUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "userPayload": userPayload,
        'agentId': agentId,
        'sessionId': sessionId ?? _sessionId,
        'languageCode': (language?.isNotEmpty ?? false) ? language : 'en-US',
      }),
    );

    // print('Response status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      final newSessionId = responseJson['sessionId'] as String?;
      final metaData = responseJson['metaData'] as Map<String, dynamic>?;

      if (newSessionId != null) {
        _sessionId = newSessionId;
      }

      List<dynamic>? payload;
      String? textMessage;
      if (metaData != null && metaData.containsKey('payload')) {
        payload = metaData['payload'] as List<dynamic>;
        final textItem = payload.firstWhere(
              (item) => item['type'] == 'text',
          orElse: () => null,
        );
        if (textItem != null) {
          textMessage = textItem['data']['message'] as String?;
        }
      }

      return ResponseMessage(
        MessageType.bot,
        DateTime.now(),
        text: textMessage,
        sessionId: _sessionId,
        wholeResponsePayload: responseJson,
        haivaMessage: metaData,
        payload: payload,
        statusCode: response.statusCode,
      );
    } else {
      // print('Error: ${response.statusCode} - ${response.body}');
      return ResponseMessage(
        MessageType.bot,
        DateTime.now(),
        text: 'Sorry, an error occurred. Please try again later.',
      );
    }
  }

}
