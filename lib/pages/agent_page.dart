import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/agent_provider.dart';
import '../constants.dart'; // Ensure this is the correct path to your constants file
import '../models/agent.dart';
import 'configure_page.dart';

class AgentsPage extends StatefulWidget {
  final String agentid;
  const AgentsPage({Key? key, required this.agentid}) : super(key: key);
  @override
  _AgentsPageState createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkspaceAndFetchAgents();
    });
  }

  Future<void> _initializeWorkspaceAndFetchAgents() async {
    // Check if the workspaceId is set in Constants
    if (Constants.workspaceId == null) {
      // Display error if workspaceId is not available
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }

    try {
      await Provider.of<AgentProvider>(context, listen: false).fetchAgents(Constants.workspaceId!);
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print("Error fetching agents");
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _refreshAgents() async {
    await _initializeWorkspaceAndFetchAgents();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Agents'),
      ),
      child: SafeArea(
        child: _loading
            ? Center(child: CupertinoActivityIndicator()) // Show loading spinner
            : _error
            ? Center(child: Text('Error loading agents. Please check workspace ID.')) // Show error message
            : CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CupertinoSearchTextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {}); // Trigger UI update on search
                        },
                      ),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      flex: 0,
                      child: CupertinoButton(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF19437D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Wrap(
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
                              builder: (context) => ConfigureEditPage(agentId: widget.agentid,),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                      Agent agent = filteredAgents[index];
                      return Dismissible(
                        key: Key(agent.id??''),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            return await showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                final TextEditingController _confirmationController = TextEditingController();
                                return CupertinoAlertDialog(
                                  title: Text('Confirm Deletion'),
                                  content: Column(
                                    children: [
                                      Text('Are you sure?'),
                                      SizedBox(height: 16),
                                      CupertinoTextField(
                                        controller: _confirmationController,
                                        placeholder: 'Type DELETE to confirm',
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(false),
                                    ),
                                    CupertinoDialogAction(
                                      child: Text('Delete'),
                                      onPressed: () {
                                        if (_confirmationController.text == 'DELETE') {
                                          Navigator.of(context).pop(true);
                                        } else {
                                          Navigator.of(context).pop(false);
                                          showCupertinoDialog(
                                            context: context,
                                            builder: (context) => CupertinoAlertDialog(
                                              title: Text('Error'),
                                              content: Text('Please type DELETE to confirm'),
                                              actions: [
                                                CupertinoDialogAction(
                                                  child: Text('OK'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          Provider.of<AgentProvider>(context, listen: false).deleteAgent(agent.id??'');
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Agent deleted'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                        background: Container(
                          color: CupertinoColors.systemRed,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Icon(CupertinoIcons.delete, color: CupertinoColors.white),
                            ),
                          ),
                        ),
                        child: CupertinoListTile(
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
                                builder: (context) => ConfigureEditPage(agentId: agent.id!,),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: filteredAgents.length,
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
