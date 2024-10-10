import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TextToSpeechService {
  final String baseUrl = 'https://services-stage.haiva.ai/v1/speech/text-to-speech';

  Future<Uint8List> textToSpeech(String text, String language,String? voice) async {

    final Map<String, dynamic> body = {
      'language': language,
      'text': text,
    };

    if (voice != null) {
      body['voice'] = voice;
    }

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;  // This returns the audio data as bytes.
    } else {
      throw Exception('Failed to convert text to speech');
    }
  }

  Future<List<dynamic>> getAllVoices() async {
    try {
      final url = Uri.parse('https://services-stage.haiva.ai/v1/speech/voices');
      final response = await http.get(url);
      print('>>>>>>>>${response}');
      if (response.statusCode == 200) {
        final List<dynamic> voices = json.decode(response.body);
        return voices;
      } else {
        throw Exception('Failed to retrieve voices. Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<Uint8List> callApiForVoice(dynamic voiceLabel) async {
    final String url = 'https://services-stage.haiva.ai/v1/speech/text-to-speech';
    final language = 'en-US';
    final text = "Hello! from HAIVA. I'm a AI powered Multilingual Voice agent.";

    final requestBody = {
      "language": language,
      "text": text,
      "voice": voiceLabel
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      print('Voice Response${response.bodyBytes}');
      return response.bodyBytes;
    } else {
      throw Exception('Failed to convert text to speech');
    }
  }

}
