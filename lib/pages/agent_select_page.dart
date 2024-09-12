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
  bool _loadingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
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

      bool success = await authService.logout();
      if (success) {
        authService.isAuthenticated() == false;
        // Constants.accessToken = null;
        // Constants.workspaceId = null;
        // Constants.orgId = null;
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => OnboardingPage()),
              (route) => false, // Clear the entire navigation stack
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

    await _fetchAgents();
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
    return CupertinoPageScaffold(
      navigationBar:CupertinoNavigationBar(
        middle: Text('Agents'),
        trailing: Container(
          // Add padding to adjust alignment
          child: CupertinoButton(
            padding: EdgeInsets.zero, // Remove default padding from the button
            onPressed: () {
              _showLogoutDialog();
            },
            child: Icon(
              CupertinoIcons.power,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),

      child: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_initialLoading) {
      return Center(child: CupertinoActivityIndicator());
    }
    if (_error) {
      return Center(child: Text('Error loading data. Please try again.'));
    }
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSearchBar(),
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: 100.0,
          onRefresh: _refreshAgents,
        ),
        _buildAgentList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:Row(
          children: [
            Expanded(
              flex: 5,
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {}); // Trigger UI update on search
                },
              ),
            ),

            Expanded(
              flex: 5,
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
            )
          ],
        ),
      ),
    );
  }

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

  Widget _buildDismissibleAgentTile(Agent agent) {
    return Dismissible(
      key: Key(agent.id??''),
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

  Widget _buildAgentTile(Agent agent) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => MainNavigationPage(agentId: agent.id??''),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: agent.agentConfigs?.image != null &&
                    agent.agentConfigs?.image != NetworkImageLoadException
                    ? Image.network(
                  agent.agentConfigs!.image!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  CupertinoIcons.person_fill,
                  size: 40,
                  color: CupertinoColors.systemGrey3,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent.name!,
                      style: TextStyle(
                          fontFamily: GoogleFonts.raleway().fontFamily,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      agent.description!,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Icon(
                  //   agent.isDeployed
                  //       ? CupertinoIcons.check_mark_circled
                  //       : CupertinoIcons.xmark_circle,
                  //   color: agent.isDeployed
                  //       ? CupertinoColors.activeGreen
                  //       : CupertinoColors.systemRed,
                  // ),
                  SizedBox(height: 4),
                  Text(
                    agent.isDeployed??true ? 'DEPLOYED' : 'NOT DEPLOYED',
                    style: TextStyle(
                      fontFamily: GoogleFonts.raleway().fontFamily,
                      color: agent.isDeployed??true
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}