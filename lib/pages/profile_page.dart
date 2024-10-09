import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../services/auth_service.dart';
import 'onboard.dart';

class ProfilePage extends StatefulWidget {
  final String agentId;
  ProfilePage({Key? key, required this.agentId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final AuthService authService = AuthService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Agent>(
          future: _agentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No agent data found'));
            } else {
              return _buildProfileContent(context, snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Agent agent) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          _buildAgentInfo(context, agent),
          SizedBox(height: 16),
          _buildAgentDetails(context, agent),
          SizedBox(height: 16),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // Widget _buildAvatar(BuildContext context, Agent agent) {
  Widget _buildAgentInfo(BuildContext context, Agent agent) {
    return Column(
      children: [
        Text(
          agent.name ?? 'Unknown Agent',
          textAlign:  TextAlign.center,
          style:TextStyle(
            fontFamily: GoogleFonts.raleway().fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 24
        ),
        ),
        SizedBox(height: 8),
        Text(
          'Agent ID: ${agent.id ?? 'Unknown ID'}',
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAgentDetails(BuildContext context, Agent agent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(context, 'Name', agent.agentConfigs?.displayName ?? 'N/A', CupertinoIcons.person),
        _buildDetailItem(context, 'Type', agent.type ?? 'N/A', CupertinoIcons.tag),
        _buildDetailItem(context, 'Description', agent.description ?? 'N/A', CupertinoIcons.info),
        _buildDetailItem(
            context,
            'Deployment Status',
            agent.isDeployed ?? false ? 'Deployed' : 'Not Deployed',
            agent.isDeployed ?? false ? CupertinoIcons.check_mark_circled : CupertinoIcons.xmark_circle
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: CupertinoColors.activeBlue, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.destructiveRed,
      child: Text('Logout'),
      onPressed: () async => await _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool logoutSuccessful = await authService.logout();

    if (logoutSuccessful) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Logout Successful'),
          content: Text('You have been logged out of the app.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => OnboardingPage()),
                      (route) => false,
                );
                //  exit(0);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

    } else {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Logout Error'),
          content: Text('There was an unexpected error during logout. Please try again or restart the app.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Logout Error'),
        content: Text(message),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}