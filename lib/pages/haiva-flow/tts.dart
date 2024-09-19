import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TextToSpeechService {
  final String baseUrl = 'https://services-stage.haiva.ai/v1/speech/text-to-speech';

  Future<Uint8List> textToSpeech(String text, String language) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'language': language,
        'text': text,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;  // This returns the audio data as bytes.
    } else {
      print('Error converting text to speech: ${response.statusCode}');
      print('Error converting text to speech: ${response.body}');
      throw Exception('Failed to convert text to speech');
    }
  }
}
