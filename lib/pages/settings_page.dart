import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/pages/configure_page.dart';
import 'package:haivanalytics/pages/connection_page.dart';
import 'package:haivanalytics/pages/talk_page.dart';
import 'package:haivanalytics/theme/colortheme.dart';
import 'package:provider/provider.dart';

import '../models/agent.dart';
import '../providers/agent_provider.dart';
import 'deploy_info.dart';
import 'haiva-flow/flow_chat_haiva.dart';

class SettingsPage extends StatefulWidget {
  final String agentId;
  const SettingsPage({super.key, required this.agentId});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _completedStep = 0;
  late Future<Agent> _agentFuture;

  @override
  void initState() {
    super.initState();
    _agentFuture = _loadAgentData();
  }

  Future<Agent> _loadAgentData() async {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    return await agentProvider.getAgentById(widget.agentId);
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
        page = DeployInfoPage(agent: widget.agentId);
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorTheme.primary,
        centerTitle: true,
        title: Text('Agent Settings'),
      ),
      body: SafeArea(

        child: FutureBuilder<Agent>(
          future: _agentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final agent = snapshot.data!;
              return Column(
                children: [
                  _buildAgentDetailsSection(agent),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildCard(
                          context,
                          'Agent Configuration',
                          'Collect details like color name and description of the agent.',
                          Color(0xFF19437D).withOpacity(0.6),
                          0,
                          CupertinoIcons.info,
                        ),
                        _buildCard(
                          context,
                          'Configure TALK/SPEECH',
                          'Configure the language and communication settings, and adjust various linguistic parameters to ensure effective understanding and interaction.',
                          Color(0xFF19437D).withOpacity(0.7),
                          1,
                          CupertinoIcons.textformat_alt,
                        ),
                        _buildCard(
                          context,
                          'Fetching from database',
                          'Uploading and organizing the data that will be used. Import various data sources to ensure all necessary information is available for accurate responses.',
                          Color(0xFF19437D).withOpacity(0.8),
                          2,
                          CupertinoIcons.cloud_download,
                        ),
                        _buildCard(
                          context,
                          'Deploy Information',
                          'Set up the deployment environment, and launch the configuration to start interacting with users. Ensure everything is live and operational for real-world usage.',
                          Color(0xFF19437D).withOpacity(0.9),
                          3,
                          CupertinoIcons.device_phone_portrait,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
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
  Widget _buildAgentDetailsSection(Agent agent) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Color(0xFF19437D).withOpacity(0.1),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFF19437D),
            radius: 30,
            child: ClipOval(
              child: agent.agentConfigs?.image != null
                  ? Image.network(
                agent.agentConfigs!.image!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                 //   Icon(Icons.error, color: Colors.white, size: 30),
                Image.asset('assets/haiva.png', width: 60, height: 60, fit: BoxFit.contain),
              )
                  : Icon(Icons.person, color: Colors.white, size: 30),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name ?? 'Unnamed Agent',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Agent ID: ${widget.agentId}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                _buildRedirectButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRedirectButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Replace with the page you want to navigate to
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HaivaChatScreen(agentId: widget.agentId)),
        );
      },
      // icon: Icon(CupertinoIcons.arrow_right),
      label: Text("Go to Chat",style: TextStyle(color: Colors.white),),
      style: ElevatedButton.styleFrom(

        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        backgroundColor: Color(0xFF19437D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: Size(80, 30),
      ),
    );
  }
}
