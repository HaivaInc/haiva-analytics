import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../widget/cupertino_filter_chip.dart';
import 'haiva-flow/tts.dart';
import 'dart:typed_data';

class TalkPage extends StatefulWidget {
  final String agentId;
  const TalkPage({Key? key, required this.agentId}) : super(key: key);

  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ttsService = TextToSpeechService();
  String _searchQuery = '';
  bool _isLoading = false;
  List<dynamic> allVoices = [];
  String? selectedVoice; // To store the selected voice code
  String selectedGender = 'neutral'; // Default to 'neutral'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAgentConfig();
    _getVoices();

  }

  Future<void> _getVoices() async {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    print("-++++++-=-=-${agentProvider.voice_code}");

    try {
      allVoices = await ttsService.getAllVoices();
      if (allVoices.isNotEmpty) {
        print("-=-=-=-=-=-${allVoices}");
        print("-=-=-=-=-=-${agentProvider.voice_code}");
        print("selected-=-=-=-=-${selectedVoice}");
        setState(() {
           if (agentProvider.voice_code == '') {
             selectedVoice = allVoices[0]['code'];
          }
        });
      } else {
        setState(() {
          selectedVoice = 'de-DE-FlorianMultilingualNeural';
        });
      }
    } catch (e) {
      print('Error fetching voices: $e');
    }
  }


  Widget _getVoiceLabel(dynamic voice) {
    String gender = voice['gender'];
    String imagePath;
    if (gender == 'Female') {
      imagePath = 'assets/images/female.webp';
    } else {
      imagePath = 'assets/images/male.png';
    }

    return Row(
      children: [
        Image.asset(imagePath, height: 24, width: 24),
        SizedBox(width: 8),
        Text(voice['name']),
      ],
    );
  }


  void _loadAgentConfig() async {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    try {
      final agent = await agentProvider.getAgentById(widget.agentId);
      print('Loaded agent config: ${agent.agentConfigs?.languages}');
      agentProvider.updateAgentConfig(agent.agentConfigs!);
      setState(() {}); // Force rebuild after config update
    } catch (e) {
      print('Error loading agent config: $e');
    }
  }

  void _showGenderFilterOptions() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text("Select Voice Gender"),
          actions: [
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Male"),
                  if (selectedGender == 'Male') Icon(CupertinoIcons.checkmark)
                ],
              ),
              onPressed: () {
                setState(() {
                  selectedGender = 'Male';
                  Navigator.pop(context);
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Female"),
                  if (selectedGender == 'Female') Icon(CupertinoIcons.checkmark)
                ],
              ),
              onPressed: () {
                setState(() {
                  selectedGender = 'Female';
                  Navigator.pop(context);
                });
              },
            ),
            CupertinoActionSheetAction(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Neutral"),
                  if (selectedGender == 'neutral') Icon(CupertinoIcons.checkmark)
                ],
              ),
              onPressed: () {
                setState(() {
                  selectedGender = 'neutral';
                  Navigator.pop(context);
                });
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancel"),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context);

    // Filter voices based on selected gender
    List<dynamic> filteredVoices = selectedGender == 'neutral'
        ? allVoices
        : allVoices.where((voice) => voice['gender'] == selectedGender).toList();
    if (filteredVoices.isNotEmpty && !filteredVoices.any((voice) => voice['code'] == selectedVoice)) {
      if (agentProvider.voice_code == '') {
        selectedVoice = filteredVoices[0]['code'];
      }
    } else if (filteredVoices.isEmpty) {
      selectedVoice = null; // Set to null if no voices match the filter
    }

    List<String> filteredLanguages = agentProvider.languageCodes.keys
        .where((language) => language.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF19437D),
        centerTitle: true,
        title: Text('Configure TALK/SPEECH'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configure the language and communication settings, and adjust various linguistic parameters to ensure effective understanding and interaction",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enable Voice Interaction', style: TextStyle(color: Color(0xFF19437D))),
                  CupertinoSwitch(
                    activeColor: Color(0xFF19437D),
                    value: agentProvider.speechToTextEnabled,
                    onChanged: (bool value) {
                      agentProvider.toggleSpeechToText(value);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text("Select Languages ↓ "),
              SizedBox(height: 10),
              CupertinoTextField(
                controller: _searchController,
                placeholder: 'Search languages',
                prefix: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(CupertinoIcons.search, color: CupertinoColors.systemGrey),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Container(
                height: 180,
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: filteredLanguages.map((String language) {
                      return CupertinoFilterChip(
                        label: language,
                        selected: agentProvider.selectedLanguages.contains(language),
                        selectedColor: Color(0xFF19437D),
                        onSelected: (bool selected) {
                          setState(() {
                            agentProvider.toggleLanguageSelection(language);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              Text("Select Voice ↓ "),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedVoice ?? agentProvider.voice_code,
                      hint: Text('Select Voice'),
                      dropdownColor: Colors.white,
                      // Inside your DropdownButton's items map
                      items: filteredVoices.map<DropdownMenuItem<String>>((dynamic voice) {
                        return DropdownMenuItem<String>(
                          value: voice['code'], // Store the voice code
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _getVoiceLabel(voice)),
                              InkWell(
                                onTap: () async {
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    Uint8List audioBytes = await ttsService.callApiForVoice(voice['code']);
                                    try {
                                      await _audioPlayer.play(BytesSource(audioBytes));
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                },
                                child: Icon(
                                  Icons.volume_up,
                                  color: Color(0xFF19437D),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedVoice = newValue;
                          agentProvider.updateVoiceCode(newValue);
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_alt_outlined, color: Color(0xFF19437D)), // Filter icon
                    onPressed: () {
                      _showGenderFilterOptions();
                    },
                  ),
                ],
              ),
              Spacer(),
              Container(
                width: double.infinity,
                child: CupertinoButton(
                  color: Color(0xFF19437D),
                  child: Text('Save Changes'),
                  onPressed: () async {
                    final agent = Agent(
                      id: widget.agentId,
                      agentConfigs: AgentConfigs(
                        languages: agentProvider.getSelectedLanguageCodes(),
                        isSpeech2text: agentProvider.speechToTextEnabled,
                        displayName: agentProvider.displayName,
                        image: agentProvider.image,
                        colors: agentProvider.colors,
                          voice_code: selectedVoice,
                      ),
                    );

                    try {
                      await agentProvider.updateAgent(agent);
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('Update Failed'),
                            content: Text('Failed to update agent: ${e.toString()}'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
