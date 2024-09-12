import 'package:flutter/cupertino.dart';
import 'package:haivanalytics/pages/chat_page.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../constants.dart'; // Ensure this is the correct path to your constants file
import '../models/agent.dart';
import '../providers/workspace_provider.dart';
import '../services/workspace_id_service.dart';
import 'configure_page.dart';

class AgentsChatPage extends StatefulWidget {
  final String agentid;
  AgentsChatPage({super.key, required this.agentid});
  @override
  _AgentsChatPageState createState() => _AgentsChatPageState();
}

class _AgentsChatPageState extends State<AgentsChatPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  bool _error = false;
  bool _initialLoading = true; // Define this variable
  bool _loadingMore = false; // Define this variable
  final ScrollController _scrollController = ScrollController(); // Define this variable

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces();
  }

  Future<void> _fetchWorkspaces() async {
    try {
      final workspaceService = WorkspaceService();
      final workspaceIds = await workspaceService.getWorkspaces();
      Provider.of<WorkspaceProvider>(context, listen: false).setWorkspaces(workspaceIds);
      Constants.workspaceId = workspaceIds[0];
    } catch (e) {
      print('Error fetching workspaces: $e');
      // Handle error (e.g., show an alert)
    }
  }

  Future<void> _refreshAgents() async {
    _fetchWorkspaces();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Agent'),
      ),
      child: SafeArea(
        child: _initialLoading
            ? Center(child: CupertinoActivityIndicator()) // Show loading spinner
            : _error
            ? Center(child: Text('Error loading agents. Please check workspace ID.')) // Show error message
            : CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Trigger UI update on search
                  },
                ),
              ),
            ),
            CupertinoSliverRefreshControl(
              refreshTriggerPullDistance: double.infinity,
              onRefresh: _refreshAgents,
            ),
            Consumer<AgentProvider>(
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
                            ? Center(child: CupertinoActivityIndicator()) // Show loading spinner at bottom
                            : SizedBox.shrink();
                      }

                      Agent agent = filteredAgents[index];
                      return CupertinoListTile(
                        title: Text(agent.name??''),
                        subtitle: Text(agent.description??''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              agent.isDeployed??true
                                  ? CupertinoIcons.check_mark_circled
                                  : CupertinoIcons.xmark_circle,
                              color: agent.isDeployed??false
                                  ? CupertinoColors.activeGreen
                                  : CupertinoColors.systemRed,
                            ),
                            SizedBox(width: 8),
                            Text(
                              agent.isDeployed??true ? 'Deployed' : 'Not Deployed',
                              style: TextStyle(
                                color: agent.isDeployed??false
                                    ? CupertinoColors.activeGreen
                                    : CupertinoColors.systemRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ChatPage(agentId: agent.id??''),
                            ),
                          );
                        },
                      );
                    },
                    childCount: filteredAgents.length + (_loadingMore ? 1 : 0), // Add one for the loading indicator
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
