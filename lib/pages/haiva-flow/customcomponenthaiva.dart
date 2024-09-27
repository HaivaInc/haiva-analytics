import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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
  final bool stopSpeaking;

  const CustomComponentHaiva({
    required this.payload,
    required this.onButtonPressed,
    required this.onFormSubmit,
    required  this.stopSpeaking,
    Key? key,
    this.locale,
  }) : super(key: key);

  @override
  State<CustomComponentHaiva> createState() => _CustomComponentHaivaState();
}

class _CustomComponentHaivaState extends State<CustomComponentHaiva> {
  late String locale;
  String? _selectedLocale;
  bool _isSpeaking = false; // Track whether speech is ongoing
  bool _isLoading = false;
  final TextToSpeechService _ttsService = TextToSpeechService();
  final AudioPlayer _audioPlayer = AudioPlayer(); // Initialize AudioPlayer here
  final Map<String, Uint8List> _cachedAudio = {};
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
    'ta-In':'Tamil',
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
  String? _lastSpokenMessage;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.locale ?? 'en-US';


    void _speakFirstMessage(dynamic payload) {
      for (var item in payload) {
        if (item is Map<String, dynamic> && item['type'] == 'text') {
          final message = item['data']['message'];
          if (message != _lastSpokenMessage) {
            _speak(message);
            _lastSpokenMessage = message; // Update the last spoken message
            break; // Speak only the first message
          }
        }
      }
    }
    if (widget.payload is List && widget.payload.isNotEmpty) {
      if (!widget.stopSpeaking) {
        _speakFirstMessage(widget.payload);
      }
    }
    _audioPlayer.onPlayerComplete.listen((_) {
      print("Audio playback completed");
      setState(() {
        _isSpeaking = false;
      });
    }
    );

    if (!widget.stopSpeaking) {
      WidgetsBinding.instance.addPostFrameCallback((_) {

        if (widget.payload is List) {
          for (var item in widget.payload) {
            if (item is Map<String, dynamic> && item['type'] == 'text') {
              final message = item['data']['message'];
              if (message != _lastSpokenMessage) {
                _speak(message);
                _lastSpokenMessage = message; // Update the last spoken message
              }

            }
          }
        }

      });
    }
  }
  Future<void> convertTextToSpeechAndPlay(String text, String language) async {
    try {
      Uint8List audioBytes = await _ttsService.textToSpeech(text, language);

      await _audioPlayer.play(BytesSource(audioBytes)); // Use BytesSource for playing the audio
      //   print("audio playing started : $audioBytes");
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> _speak(String text) async {
    if (_isSpeaking) {

      {
        await _audioPlayer.stop();
      }

    } else {
      setState(() {
        _isLoading = true;
      });

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
        Uint8List audioBytes;
        if (_cachedAudio.containsKey(cleanText)) {
          audioBytes = _cachedAudio[cleanText]!;
        } else {
          audioBytes = await _ttsService.textToSpeech(cleanText, _selectedLocale ?? 'en-US');
          _cachedAudio[cleanText] = audioBytes;
        }


       {
          await _audioPlayer.play(BytesSource(audioBytes));
          _audioPlayer.onPlayerComplete.listen((_) {
            setState(() {
              _isSpeaking = false;
            });
          });
        }
      } catch (e) {
        print('Error playing audio: $e');
        setState(() {
          _isLoading = false;
          _isSpeaking = false;
        });
      }
    } }
  //
  // Future<void> _stopSpeaking() async {
  //   if (kIsWeb) {
  //     js.context.callMethod('eval', ['if (typeof howl !== "undefined") { howl.stop(); }']);
  //   } else {
  //     await _audioPlayer.stop();
  //   }
  //   setState(() {
  //     _isSpeaking = false; // Update the speaking state
  //   });
  // }
  //
  // Future<void> _startSpeaking(String text) async {
  //   setState(() {
  //     _isLoading = true; // Indicate loading
  //   });
  //
  //   String cleanText = md.markdownToHtml(text)
  //       .replaceAll(RegExp(r'<[^>]*>'), '')
  //       .replaceAll('&amp;', '&')
  //       .replaceAll('&lt;', '<')
  //       .replaceAll('&gt;', '>')
  //       .replaceAll('&quot;', '"')
  //       .replaceAll('&apos;', "'")
  //       .replaceAll('|', ' ')
  //       .replaceAll('-', ' ')
  //       .replaceAll('.', ' ')
  //       .replaceAll('\n', ' ')
  //       .toLowerCase()
  //       .replaceAll(RegExp(r'\s{2,}'), ' ')
  //       .trim();
  //
  //   try {
  //     Uint8List audioBytes;
  //     if (_cachedAudio.containsKey(cleanText)) {
  //       audioBytes = _cachedAudio[cleanText]!;
  //     } else {
  //       audioBytes = await _ttsService.textToSpeech(cleanText, _selectedLocale ?? 'en-US');
  //       _cachedAudio[cleanText] = audioBytes;
  //     }
  //
  //     if (kIsWeb) {
  //       final base64Audio = base64Encode(audioBytes);
  //       final audioUrl = 'data:audio/mp3;base64,$base64Audio';
  //
  //       js.context.callMethod('eval', [ '''
  //     if (typeof howl !== "undefined") {
  //       howl.stop();
  //       howl.unload();
  //     }
  //
  //     var howl = new Howl({
  //       src: ['$audioUrl'],
  //       format: ['mp3'],
  //       onend: function() {
  //         window.flutter_inappwebview.callHandler('onAudioComplete');
  //       }
  //     });
  //     howl.play();
  //     ''' ]);
  //       _isSpeaking = true;
  //     } else {
  //       await _audioPlayer.play(BytesSource(audioBytes));
  //     }
  //
  //     setState(() {
  //       _isSpeaking = true; // Update speaking state
  //       _isLoading = false; // Hide loading
  //     });
  //   } catch (e) {
  //     print('Error playing audio: $e');
  //     setState(() {
  //       _isLoading = false;
  //       _isSpeaking = false; // Update speaking state
  //     });
  //   }
  // }


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
                //   final bool hasVoice = _localeToVoiceMap.containsKey(_selectedLocale);
                children.add(
                    Stack(
                      alignment: Alignment.bottomRight,
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 30, bottom: 20),  // Add padding to make room for the button
                          child: BubbleWidget(
                            widget: SelectableMarkdown(data: data['message']),
                          ),
                        ),
                        Positioned(
                          right: 35,

                          child: Container(
                            width: 25,
                            height: 25,
                            margin: const EdgeInsets.only(bottom: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: ColorTheme.primary.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(  // Ensure the icon is centered
                              child: _isLoading
                                  ? CupertinoActivityIndicator(color: ColorTheme.primary)
                                  : IconButton(
                                padding: EdgeInsets.zero,
                                color: ColorTheme.primary, onPressed: () {
                                _speak(data['message']);

                              },
                                icon: _isSpeaking ?Icon(Icons.volume_up_rounded): Icon(Icons.volume_off)  ,
                                iconSize: 15,
                              ),
                            ),
                          ),
                        ),

                      ],
                    )
                );
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
