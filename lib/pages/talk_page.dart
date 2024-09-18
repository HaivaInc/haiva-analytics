import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/theme/colortheme.dart';
import 'package:provider/provider.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../widget/cupertino_filter_chip.dart';

class TalkPage extends StatefulWidget {
  final String agentId;
  const TalkPage({Key? key, required this.agentId}) : super(key: key);

  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAgentConfig();
  }

  void _loadAgentConfig() async {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    try {
      final agent = await agentProvider.getAgentById(widget.agentId);
      agentProvider.updateAgentConfig(agent.agentConfigs!);
    } catch (e) {
      print('Error loading agent config: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context);

    List<String> filteredLanguages = agentProvider.languageCodes.keys
        .where((language) => language.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.primary,
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

              SizedBox(height: 20),
              Text(
                "Select Languages ↓ ",
              ),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: filteredLanguages.map((String language) {
                      return CupertinoFilterChip(
                        label: language,
                        selected: agentProvider.selectedLanguages.contains(language),
                        selectedColor: ColorTheme.primary,
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Speech to Text', style: TextStyle(color: ColorTheme.primary)),
                  CupertinoSwitch(
                    activeColor: ColorTheme.primary,
                    value: agentProvider.speechToTextEnabled,
                    onChanged: (bool value) {
                      agentProvider.toggleSpeechToText(value);
                    },
                  ),
                ],
              ),
              Spacer(),
              Container(
                width: double.infinity,
                child: CupertinoButton(
                  color: ColorTheme.primary,
                  child: Text('Next'),
                  onPressed: () async {
                    final agent = Agent(
                      id: widget.agentId,
                      agentConfigs: AgentConfigs(
                        languages: agentProvider.selectedLanguages,
                        isSpeech2text: agentProvider.speechToTextEnabled,
                        displayName: agentProvider.displayName,
                        image: agentProvider.image,
                        colors: agentProvider.colors,
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