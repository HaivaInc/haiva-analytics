import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:haivanalytics/pages/haiva-flow/tts.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../theme/colortheme.dart';
import '../../widget/bubble.dart';
import '../../widget/button.dart';
import '../../widget/chart.dart';
import '../../widget/form.dart';
import '../../widget/selectmarkdown.dart';
import '../../widget/table.dart';

class CustomComponentHaiva extends StatefulWidget {
  final dynamic payload;
  final Function(String, bool) onButtonPressed;
  final Function(Map<String, dynamic>) onFormSubmit;
  final String? locale;

  const CustomComponentHaiva({
    required this.payload,
    required this.onButtonPressed,
    required this.onFormSubmit,
    Key? key,
    this.locale,
  }) : super(key: key);

  @override
  State<CustomComponentHaiva> createState() => _CustomComponentHaivaState();
}

class _CustomComponentHaivaState extends State<CustomComponentHaiva> {
  late String locale;
  String? _selectedLocale;
  bool _isLoading = false;
  bool _isSpeaking = false; // Track whether speech is ongoing
  final TextToSpeechService _ttsService = TextToSpeechService();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer here

  final Map<String, String> _localeToVoiceMap = {
    'en-GB': 'Google UK English Female', // UK English Female
    'en-US': 'Google US English ', // US English
    'it-IT': 'Google italiano', // Italian
    'sv-SE': 'Alva', // Swedish
    'fr-CA': 'Amélie', // French Canadian
    'ms-MY': 'Amira', // Malay
    'de-DE': 'Eddy (German (Germany))', // German
    'he-IL': 'Carmit', // Hebrew
    'en-AU': 'Catherine', // Australian English
    'id-ID': 'Damayanti', // Indonesian
    'fr-FR': 'Eddy (French (France))', // French
    'bg-BG': 'Daria', // Bulgarian
    'fi-FI': 'Eddy (Finnish (Finland))', // Finnish
    'es-ES': 'Eddy (Spanish (Spain))', // Spanish (Spain)
    'es-MX': 'Eddy (Spanish (Mexico))', // Spanish (Mexico)
    'pt-BR': 'Eddy (Portuguese (Brazil))', // Portuguese (Brazil)
    'nl-BE': 'Ellen', // Dutch (Belgium)
    'ja-JP': 'Hattori', // Japanese
    'ro-RO': 'Ioana', // Romanian
    'zh-CN': 'Li-Mu', // Mandarin Chinese (China)
    'vi-VN': 'Linh', // Vietnamese
    'ar-001': 'Majed', // Arabic
    'zh-TW': 'Meijia', // Mandarin Chinese (Taiwan)
    'el-GR': 'Melina', // Greek
    'ru-RU': 'Milena', // Russian
    'en-IE': 'Moira', // English (Ireland)
    'ca-ES': 'Montse', // Catalan
    'pt-PT': 'Luciana', // Portuguese (Portugal)
    'th-TH': 'Kanya', // Thai
    'hr-HR': 'Lana', // Croatian
    'sk-SK': 'Laura', // Slovak
    'hi-IN': 'Lekha', // Hindi
    'uk-UA': 'Lesya', // Ukrainian
    'zh-HK': 'Sinji', // Cantonese (Hong Kong)
    'pl-PL': 'Zosia', // Polish
    'cs-CZ': 'Zuzana', // Czech
    'ta-IN':'Tamil',
    'hu-HU': 'Tünde', // Hungarian
    'tr-TR': 'Yelda', // Turkish
    'ko-KR': 'Yuna', // Korean
    'da-DK': 'Sara', // Danish
    'nb-NO': 'Nora', // Norwegian
    'en-ZA': 'Tessa', // English (South Africa)
    'hu-HU': 'Tünde', // Hungarian
    'cs-CZ': 'Zuzana', // Czech
    'pl-PL': 'Zosia', // Polish
    'tr-TR': 'Yelda', // Turkish
    'ko-KR': 'Yuna', // Korean
    'da-DK': 'Sara', // Danish
    'nb-NO': 'Nora', // Norwegian
    'en-ZA': 'Tessa', // English (South Africa)
    'zh-TW': 'Meijia', // Mandarin Chinese (Taiwan)
    'es-US': 'Google español de Estados Unidos', // Spanish (US)
    'en-IN': 'Rishi', // English (India)
    'en-IE': 'Moira', // English (Ireland)
    'ar-001': 'Majed', // Arabic
    'zh-CN': 'Yu-shu', // Mandarin Chinese (China)
  };


  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.locale ?? 'en-US';
  }

  Future<void> convertTextToSpeechAndPlay(String text, String language) async {
    try {
      Uint8List audioBytes = await _ttsService.textToSpeech(text, language);
      await _audioPlayer.play(BytesSource(audioBytes)); // Use BytesSource for playing the audio
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _audioPlayer.stop(); // Stop any ongoing speech
      setState(() {
        _isSpeaking = false;
      });
    } else {
      // Clean up markdown text
      String cleanText = md.markdownToHtml(text)
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'")
          .replaceAll('|', ' ')
          .replaceAll('-', ' ')
          .replaceAll('.', ' ')
          .replaceAll('\n', ' ')
          .toLowerCase()
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();

      try {
        // Call your TTS service
        final audioBytes = await _ttsService.textToSpeech(cleanText, _selectedLocale ?? 'en-US');
        await _audioPlayer.play(BytesSource(audioBytes)); // Use BytesSource
        setState(() {
          _isSpeaking = true;
        });

        // Listen for completion
        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() {
            _isSpeaking = false;
          });
        });
      } catch (e) {
        print('Error playing audio: $e');
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.payload is List) {
      for (var item in widget.payload) {
        if (item is Map<String, dynamic>) {
          String type = item['type'];
          dynamic data = item['data'];

          switch (type) {
            case 'text':
              if (data is Map<String, dynamic> && data.containsKey('message')) {
                final bool hasVoice = _localeToVoiceMap.containsKey(_selectedLocale);
                children.add(BubbleWidget(
                    widget: SelectableMarkdown(data: data['message']),
                    iconButton: IconButton(
                      alignment: Alignment.bottomLeft,
                      icon: _isLoading?
                      SpinKitHourGlass(color: ColorTheme.primary, size: 15):
                      Icon(
                        _isSpeaking ? Icons.volume_up_outlined : Icons.volume_off,
                        size: 15,
                        color: ColorTheme.primary,
                      ),
                      color: ColorTheme.primary,
                      onPressed: () => _speak(data['message']),
                    )
                ));
              }
              break;
            case 'chart':
              if (data is Map<String, dynamic> && data.containsKey('chartData')) {
                children.add(BubbleWidget(
                  widget: Container(
                    height: 350,
                    width: 450,
                    child: ExampleChart(chartData: jsonEncode(data['chartData'])),
                  ),
                ));
              }
              break;
            case 'table':
              if (data is Map<String, dynamic> && data.containsKey('tableData')) {
                var tableData = data['tableData'];
                if (tableData is Map<String, dynamic> && tableData.containsKey('data')) {
                  children.add(BubbleWidget(
                    widget: Container(
                      height: 350,
                      width: 450,
                      child: TableData(
                        tableData: jsonEncode(tableData['data']),
                      ),
                    ),
                  ));
                }
              }
              break;
            case 'inputField':
              if (data is Map<String, dynamic>) {
                children.add(BubbleWidget(
                    widget: TextFormField(
                      decoration: InputDecoration(
                        labelText: data['label'],
                        hintText: data['placeholder'],
                      ),
                    )));
              }
              break;
            case 'submitButton':
              if (data is Map<String, dynamic>) {
                children.add(BubbleWidget(
                    widget: CustomButton(
                      title: data['name'] ?? 'Submit',
                      onPressed: (isClicked) {
                        widget.onButtonPressed(data['action']?['message'] ?? data['name'] ?? 'Submit', isClicked);
                      },
                    )));
              }
              break;
            case 'suggestButton':
              if (data is List) {
                children.add(Padding(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: data.map((button) {
                      if (button is Map<String, dynamic>) {
                        return CustomButton(
                          title: button['title'] ?? '',
                          onPressed: (isClicked) {
                            widget.onButtonPressed(button['message'] ?? '', isClicked);
                          },
                        );
                      }
                      return SizedBox.shrink();
                    }).toList(),
                  ),
                ));
              }
              break;
            case 'form':
              if (data is List) {
                children.add(BubbleWidget(
                    widget: DynamicFormWidget(
                      payloadList: List<Map<String, dynamic>>.from(data),
                      onFormSubmit: (String message, Map<String, dynamic> formData) {
                        widget.onFormSubmit(formData);
                        widget.onButtonPressed(message, true);
                      },
                    )));
              }
              break;
          }
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
