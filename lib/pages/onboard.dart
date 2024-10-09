
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/haiva-flow/flow_chat_haiva.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../providers/agent_provider.dart';
import '../providers/workspace_provider.dart';
import '../services/auth_service.dart';
import '../services/workspace_id_service.dart';
import 'agent_select_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _isLoading = false;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String?> _getDefaultAgentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('defaultAgentId');
  }
  Future<void> _fetchWorkspaces() async {
    try {
      final workspaceService = WorkspaceService();

      final workspaceIds = await workspaceService.getWorkspaces();

      //   final orgIds = await workspaceService.getOrgIds(workspaceIds);

      if (workspaceIds.isNotEmpty) {
        Constants.workspaceId = workspaceIds[0];
        print("Constants.workspaceId: ${Constants.workspaceId}");
      }
      //
      // if (orgIds.isNotEmpty) {
      //   Constants.orgId = orgIds[0];
      //   print("Constants.orgId: ${Constants.orgId}");
      // }


      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<WorkspaceProvider>(context, listen: false).setWorkspaces(workspaceIds);
          //    Provider.of<OrgProvider>(context, listen: false).setOrgId(orgIds[0]);
        }
      });

    } catch (e) {
      print('Error fetching workspaces and org ID: $e');
      throw e;
    }
  }
  Future<void> _fetchAgents() async {
    try {
      if (mounted) {
        print("-----${Constants.workspaceId}");
        await Provider.of<AgentProvider>(context, listen: false).fetchAgents(Constants.workspaceId!);
      }
    } catch (e) {
      print('Error fetching agents: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);


    return Scaffold(

      backgroundColor: Color(0xFF19437D),
      body: SafeArea(
        child: Column(
          children: [
            // Icon at the top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Image.asset(
                'assets/haiva.png',
                scale: 5,

                filterQuality: FilterQuality.high,
                // CupertinoIcons.graph_circle_fill,

                alignment: Alignment.center,
                color: Colors.white,
              ),
            ),
            // Expanded widget to center the image carousel
            Expanded(
              child: CarouselSlider(
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  viewportFraction: 0.8,
                ),
                items: [1, 2, 3, 4, 5, 6].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: Offset(2, 3),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/onboarding_$i.png'), // Replace with your image assets
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            // Bottom text and button
            SizedBox(height: 20),
            Text(
              'Welcome to HAIVA Analytics',
              style: GoogleFonts.raleway(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                'Real-time insights, simplified data visualization, and seamless access to all your databases—at your fingertips.',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(

                backgroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: _isLoading
                  ? CupertinoActivityIndicator() :
              Text(
                'Get Started',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: Color(0xFF19437D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await authService.login();
                if (await authService.isAuthenticated()) {
                  await _fetchWorkspaces();
                  await _fetchAgents();
                  String? defaultAgentId = await _getDefaultAgentId();

//                   print('----${defaultAgentId}');
// print("-=-=-=-${agentProvider.agents[0].name}");
                  if (defaultAgentId != null && (agentProvider.name.length > 0 && agentProvider.agents.any((agent) => agent.id == defaultAgentId ))) {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HaivaChatScreen(agentId: defaultAgentId),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgentSelectionPage(),
                      ),
                    );
                  }
                }
                setState(() {
                  _isLoading = false;
                });
              },

              // onPressed: () async {
              //   await authService.login();
              //   if (await authService.isAuthenticated()) {
              //     Navigator.push(
              //       context,
              //   MaterialPageRoute(
              //         builder: (context) => Constants.agentId == null
              //             ? AgentSelectionPage()
              //             : HaivaChatScreen(agentId: Constants.agentId!),
              //       ),
              //     );
              //
              //   }
              // },
              // padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              // borderRadius: BorderRadius.circular(25),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}