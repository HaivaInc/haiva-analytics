import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/pages/configure_page.dart';
import 'package:haivanalytics/pages/connection_page.dart';
import 'package:haivanalytics/pages/talk_page.dart';
import 'package:haivanalytics/theme/colortheme.dart';

import 'deploy_info.dart';

class SettingsPage extends StatefulWidget {
  final String agentId;
  const SettingsPage({super.key, required this.agentId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _completedStep = 0;

  @override
  void initState() {
    super.initState();

  }



  void _onCardTap(int step) async {
    Widget page;
    switch (step) {
      case 0:
        page = ConfigureEditPage(agentId: widget.agentId );
        break;

      case 1:
        page = TalkPage(agentId: widget.agentId,);
        break;
      case 2:
        page = ConnectionsPage(agentId: widget.agentId,);
        break;
      case 3:
        page = DeployInfoPage(agent: widget.agentId,);
        break;
      default:
        return;
    }

    final result = await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => page),
    );
    if (result != null && result) {
      setState(() {
        _completedStep = step + 1;
      });
    }
  }

  Color _getTextColor(Color cardColor) {
    final double brightness = cardColor.computeLuminance();
    return brightness < 0.5 ? Colors.white : Colors.blue.shade900;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigationBar: const CupertinoNavigationBar(
      //   middle: Text('Settings'),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildCard(
                    context,
                    'Agent Configuration',
                    'Collect details like color name and description of the agent.',
                    //Colors.blue.shade100,
                    ColorTheme.primary.withOpacity(0.6) ,
                    0,
                    CupertinoIcons.info,
                  ),
                  _buildCard(
                    context,
                    'Configure TALK/SPEECH',
                    'Configure the language and communication settings, and adjust various linguistic parameters to ensure effective understanding and interaction.',
                    ColorTheme.primary.withOpacity(0.7) ,
                    1,
                    CupertinoIcons.textformat_alt,
                  ),
                  _buildCard(
                    context,
                    'Fetching from database',
                    'Uploading and organizing the data that will be used. Import various data sources to ensure all necessary information is available for accurate responses.',
                    ColorTheme.primary.withOpacity(0.8) ,
                    2,
                    CupertinoIcons.cloud_download,
                  ),

                  _buildCard(
                    context,
                    'Deploy Information',
                    'Set up the deployment environment, and launch the configuration to start interacting with users. Ensure everything is live and operational for real-world usage.',
                    ColorTheme.primary.withOpacity(0.9) ,
                    3,
                    CupertinoIcons.device_phone_portrait,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String description, Color cardColor, int step, IconData icon) {
    return GestureDetector(
      onTap: () => _onCardTap(step),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: step <= _completedStep ? cardColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize:14,
                          fontWeight: FontWeight.bold,
                          color: step <= _completedStep ? _getTextColor(cardColor) : Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(width: 6,),
                      Icon(
                        icon,
                        color: step <= _completedStep ? _getTextColor(cardColor) : Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(

                    description,
                    style: TextStyle(
                      fontSize:12,
                      color: step <= _completedStep ? _getTextColor(cardColor) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
