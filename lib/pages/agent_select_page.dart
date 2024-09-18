import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/nav_page.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../constants.dart';
import '../models/agent.dart';
import '../providers/workspace_provider.dart';
import '../services/auth_service.dart';
import '../services/workspace_id_service.dart';
import 'config_create_page.dart';
import 'configure_page.dart';
import 'onboard.dart';

class AgentSelectionPage extends StatefulWidget {
  @override
  _AgentSelectionPageState createState() => _AgentSelectionPageState();
}

class _AgentSelectionPageState extends State<AgentSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService authService = AuthService();
  bool _initialLoading = true;
  bool _error = false;
  String? _selectedAgentId;
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _refreshAgents();
    Timer.periodic(Duration(seconds: 10), (timer) async {
      await _fetchAgents();
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchWorkspaces();
      await _fetchAgents();
      setState(() {
        _initialLoading = false;
      });
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        _error = true;
        _initialLoading = false;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    bool logoutSuccessful = await authService.logout();

    if (logoutSuccessful) {
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
                exit(0);
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

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Logout'),
        content: Text('Do you want to log out?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No', style: TextStyle(color: CupertinoColors.destructiveRed)),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout(context);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchWorkspaces() async {
    try {
      final workspaceService = WorkspaceService();
      final workspaceIds = await workspaceService.getWorkspaces();
      Provider.of<WorkspaceProvider>(context, listen: false).setWorkspaces(workspaceIds);
      Constants.workspaceId = workspaceIds[0];
      print("Constants.workspaceId: ${Constants.workspaceId}");
    } catch (e) {
      print('Error fetching workspaces: $e');
      throw e;
    }
  }

  Future<void> _fetchAgents() async {
    try {
      await Provider.of<AgentProvider>(context, listen: false).fetchAgents(Constants.workspaceId!);
    } catch (e) {
      print('Error fetching agents: $e');
      throw e;
    }
  }

  Future<void> _refreshAgents() async {
    if (_initialLoading) {
      return; // Just exit the function without doing anything if it's loading
    }
    await _fetchAgents(); // Otherwise, fetch the agents
  }


  Future<void> _deleteAgent(Agent agent) async {
    try {
      await Provider.of<AgentProvider>(context, listen: false).deleteAgent(agent.id??'');

    } catch (e) {
      print('Error deleting agent: $e');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        primary: true,

        centerTitle: true, title: Text('Agents'),
        actions: [Container(
          // Add padding to adjust alignment
          child: CupertinoButton(
            padding: EdgeInsets.zero, // Remove default padding from the button
            onPressed: () {
              _showLogoutDialog();
            },
            child: Icon(
              CupertinoIcons.power,
              color: Colors.white,
            ),
          ),
        ),],
      ),

      body: SafeArea(
       // child: _buildContent(),
        child:Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContent()),
          ],
        )
      ),
    );
  }

  Widget _buildContent() {
    if (_initialLoading) {
      return Center(child: CupertinoActivityIndicator());
    }
    if (_error) {
      return Center(child: Text('create new agent by clicking on the \n + create agent button ',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color(0xFF19437D),
      ),));
    }
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // _buildSearchBar(),
        _buildAgentList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:Row(
        children: [
          Expanded(
            flex: 3,
            child: CupertinoSearchTextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {}); // Trigger UI update on search
              },
            ),
          ),

          Expanded(
            flex: 0,
            child: Container(
              // Add padding to adjust alignment
              child: CupertinoButton(
                padding: EdgeInsets.zero, // Remove default padding from the button
                onPressed: () { _refreshAgents(); },
                child: Icon(
                  CupertinoIcons.refresh,
                  color: Color(0xFF19437D),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CupertinoButton(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF19437D),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [

                      Icon(CupertinoIcons.add, color: CupertinoColors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "CREATE AGENT",
                        style: TextStyle(color: CupertinoColors.white, fontSize: 12),
                      ),


                    ],
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => ConfigCreatePage(),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }

  // Widget _buildAgentList() {
  //   return Consumer<AgentProvider>(
  //     builder: (context, agentProvider, child) {
  //       List<Agent> filteredAgents = _searchController.text.isEmpty
  //           ? agentProvider.agents
  //           : agentProvider.searchAgents(_searchController.text);
  //
  //       if (filteredAgents.isEmpty) {
  //         return SliverToBoxAdapter(
  //           child: Center(child: Text('No agents found.')),
  //         );
  //       }
  //
  //       return SliverList(
  //         delegate: SliverChildBuilderDelegate(
  //               (context, index) {
  //             if (index >= filteredAgents.length) {
  //               return _loadingMore
  //                   ? Center(child: CupertinoActivityIndicator())
  //                   : SizedBox.shrink();
  //             }
  //
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //               child: _buildDismissibleAgentTile(filteredAgents[index]),
  //             );
  //           },
  //           childCount: filteredAgents.length + (_loadingMore ? 1 : 0),
  //         ),
  //       );
  //     },
  //   );
  // }
  Widget _buildAgentList() {
    return Consumer<AgentProvider>(
      builder: (context, agentProvider, child) {
        List<Agent> filteredAgents = _searchController.text.isEmpty
            ? agentProvider.agents
            : agentProvider.searchAgents(_searchController.text);

        if (filteredAgents.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(child: Text('No agents found.')),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index >= filteredAgents.length) {
                return _loadingMore
                    ? Center(child: CupertinoActivityIndicator())
                    : SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildDismissibleAgentTile(filteredAgents[index]),
              );
            },
            childCount: filteredAgents.length + (_loadingMore ? 1 : 0),
          ),
        );
      },
    );
  }

  // Widget _buildDismissibleAgentTile(Agent agent) {
  //   return Dismissible(
  //     key: Key(agent.id??''),
  //     direction: DismissDirection.endToStart,
  //     background: Container(
  //       alignment: Alignment.centerRight,
  //       padding: EdgeInsets.only(right: 20),
  //       color: CupertinoColors.destructiveRed,
  //       child: Icon(
  //         CupertinoIcons.delete,
  //         color: CupertinoColors.white,
  //       ),
  //     ),
  //     confirmDismiss: (direction) async {
  //       return await _showDeleteConfirmationDialog(context, agent);
  //     },
  //     child: _buildAgentTile(agent),
  //   );
  // }

  Widget _buildDismissibleAgentTile(Agent agent) {
    return Dismissible(
      key: Key(agent.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: CupertinoColors.destructiveRed,
        child: Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context, agent);
      },
      child: _buildAgentTile(agent),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context, Agent agent) async {
    String typedText = '';
    bool canDelete = false;

    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text("Are you sure?"),
              content: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                      "To avoid any potential issues, please make sure to read this carefully!\n"
                          "This action CANNOT be undone. This will permanently delete the configuration of the selected agent."
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please type DELETE to confirm.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CupertinoTextField(
                    placeholder: "Type DELETE",
                    onChanged: (value) {
                      setState(() {
                        typedText = value;
                        canDelete = typedText == 'DELETE';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                CupertinoDialogAction(
                  child: Text("Delete"),
                  isDestructiveAction: true,
                  onPressed: canDelete
                      ? () async {
                    await _deleteAgent(agent);
                    Navigator.of(context).pop(true);
                  }
                      : null,
                ),
              ],
            );
          },
        );
      },
    ) ?? false;
  }

  // Widget _buildAgentTile(Agent agent) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         CupertinoPageRoute(
  //           builder: (context) => MainNavigationPage(agentId: agent.id??''),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: CupertinoColors.systemGrey6,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(12),
  //         child: Row(
  //
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               width: 60,
  //               height: 60,
  //               decoration: BoxDecoration(
  //                 color: CupertinoColors.systemGrey4,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: agent.agentConfigs?.image != null &&
  //                   agent.agentConfigs?.image != NetworkImageLoadException
  //                   ? Image.network(
  //                 agent.agentConfigs?.image ?? 'default_image_url',
  //                 loadingBuilder: (context, child, progress) {
  //                   if (progress == null) {
  //                     return child;
  //                   } else {
  //                     return Center(child: CircularProgressIndicator());
  //                   }
  //                 },
  //                 errorBuilder: (context, error, stackTrace) {
  //                   return Image.asset('assets/haiva.png',
  //                   fit: BoxFit.contain,);
  //                 },
  //               )
  //           : Icon(
  //                 CupertinoIcons.person_fill,
  //                 size: 40,
  //               //  color: CupertinoColors.systemGrey3,
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     agent.name!,
  //                     style: TextStyle(
  //                         fontFamily: GoogleFonts.raleway().fontFamily,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 16
  //                     ),
  //                   ),
  //                   SizedBox(height: 4),
  //                   Text(
  //                     agent.description!,
  //                     style: TextStyle(
  //                         fontFamily: GoogleFonts.raleway().fontFamily,
  //                         fontSize: 14,
  //                         color: CupertinoColors.systemGrey
  //                     ),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Column(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 // Icon(
  //                 //   agent.isDeployed
  //                 //       ? CupertinoIcons.check_mark_circled
  //                 //       : CupertinoIcons.xmark_circle,
  //                 //   color: agent.isDeployed
  //                 //       ? CupertinoColors.activeGreen
  //                 //       : CupertinoColors.systemRed,
  //                 // ),
  //                 SizedBox(height: 4),
  //                 Text(
  //                   agent.isDeployed??true ? 'DEPLOYED' : 'NOT DEPLOYED',
  //                   style: TextStyle(
  //                     fontFamily: GoogleFonts.raleway().fontFamily,
  //                     color: agent.isDeployed??true
  //                         ? CupertinoColors.activeGreen
  //                         : CupertinoColors.systemRed,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildAgentTile(Agent agent) {
    bool isDefault = Constants.agentId == agent.id;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => MainNavigationPage(agentId: agent.id!),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: isDefault
              ? Border.all(color: Color(0xFF19437D), width: 2)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgentAvatar(agent),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name ?? 'Unnamed Agent',
                      style: TextStyle(
                          fontFamily: GoogleFonts.raleway().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      agent.description ?? 'No description',
                      style: TextStyle(
                          fontFamily: GoogleFonts.raleway().fontFamily,
                          fontSize: 14,
                          color: CupertinoColors.systemGrey
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDeploymentStatus(agent),
                  SizedBox(height: 8),
                  _buildMoreOptionsButton(agent, isDefault),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMoreOptionsButton(Agent agent, bool isDefault) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Icon(CupertinoIcons.ellipsis_vertical),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                child: Text('Set as Default'),
                onPressed: () {
                  Navigator.pop(context);
                  if (agent.isDeployed ?? false) {
                    if (!isDefault) {
                      setState(() {
                        Constants.agentId = agent.id;
                      });
                      _showDefaultSetConfirmation(agent);
                    } else {
                      _showAlreadyDefaultMessage(agent);
                    }
                  } else {
                    _showDeployFirstMessage(agent);
                  }
                },
                isDestructiveAction: false,
              ),
              CupertinoActionSheetAction(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog(context, agent);
                },
                isDestructiveAction: true,
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeployFirstMessage(Agent agent) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Agent Not Deployed'),
          content: Text('Please deploy ${agent.name} before setting it as the default agent.'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlreadyDefaultMessage(Agent agent) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Already Default'),
          content: Text('${agent.name} is already set as the default agent.'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showDefaultSetConfirmation(Agent agent) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Default Agent Set'),
          content: Text('Your default agent is now set to ${agent.name}.'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSetAsDefaultButton(Agent agent) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Text(
        'Set as Default',
        style: TextStyle(
          fontFamily: GoogleFonts.raleway().fontFamily,
          color: CupertinoColors.activeBlue,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      onPressed: () {
        // Implement set as default functionality
        print('Set ${agent.name} as default');

        setState(() {
          Constants.agentId = _selectedAgentId;
        });

        // Show Cupertino Alert Dialog
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Default Agent Set'),
              content: Text('Your default agent is now set to ${agent.name}.'),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      },

    );
  }
}





Widget _buildAgentAvatar(Agent agent) {
  return Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
    //  color: CupertinoColors.sys,
      borderRadius: BorderRadius.circular(8),
    ),
    child: agent.agentConfigs?.image != null
        ? Image.network(
      agent.agentConfigs!.image!,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(child: CupertinoActivityIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/haiva.png',
          fit: BoxFit.contain,
        );
      },
    )
        : Icon(
      CupertinoIcons.person_fill,
      size: 40,
    ),
  );
}

Widget _buildDeploymentStatus(Agent agent) {
  return Padding(
    padding:  EdgeInsets.all(10.0),
    child: Column(

      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(height: 4),
        Text(
          agent.isDeployed ?? false ? 'DEPLOYED' : 'NOT DEPLOYED',
          style: TextStyle(
            fontFamily: GoogleFonts.raleway().fontFamily,
            color: agent.isDeployed ?? false
                ? CupertinoColors.activeGreen
                : CupertinoColors.systemRed,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
