import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../services/auth_service.dart';
import 'onboard.dart';

class ProfilePage extends StatelessWidget {
  final String agentId;
  ProfilePage({Key? key, required this.agentId}) : super(key: key);

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProvider>(
      builder: (context, agentProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: FutureBuilder<Agent>(
              future: agentProvider.getAgentById(agentId),
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
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, Agent agent) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SizedBox(height: 16),
          // _buildAvatar(context, agent),
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
  //   return CircleAvatar(
  //     radius: 30,
  //     backgroundColor: Color(0xFF19437D),
  //     backgroundImage: agent.agentConfigs?.image != null
  //         ? NetworkImage(agent.agentConfigs!.image!)
  //         : null,
  //     child: agent.agentConfigs?.image == null
  //         ? Text(
  //       agent.name?.toUpperCase().substring(0, 1) ?? '?',
  //       style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle.copyWith(
  //         color: CupertinoColors.white,
  //       ),
  //     )
  //         : null,
  //   );
  // }

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
    try {
      bool success = await authService.logout();
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => OnboardingPage()),
              (route) => false,
        );
      } else {
        _showErrorDialog(context, 'Logout failed. Please try again.');
      }
    } catch (e) {
      print('Error during logout: $e');
      _showErrorDialog(context, 'Logout failed. Please try again.');
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