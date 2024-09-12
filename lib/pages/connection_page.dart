import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/deploy_service.dart';
import 'connection_table_page.dart';
import 'db_config.dart';

class ConnectionsPage extends StatefulWidget {
  final String agentId;
  const ConnectionsPage({Key? key, required this.agentId}) : super(key: key);

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  final DbService _dbService = DbService();
  List<Map<String, dynamic>> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConnections();
  }

  Future<void> _fetchConnections() async {
    try {
      final response = await _dbService.getDatabaseConnection();
      print("response = ${response.body}");
      print("response.statusCode = ${response.statusCode}");
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _connections = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load connections');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch connections: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Connections'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final route = CupertinoPageRoute(
              builder: (context) => DatabaseForm(agentId: widget.agentId),
            );
            Navigator.push(context, route);
          },
          child: Icon(
            CupertinoIcons.add_circled_solid,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : _connections.isEmpty
            ? Center(child: Text('No connections found'))
            : ListView.builder(
          itemCount: _connections.length,
          itemBuilder: (context, index) {
            final connection = _connections[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CupertinoListTile(
                title: Text(connection['database_name'] ?? 'Unnamed Database'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${connection['database_type'] ?? 'Unknown'}'),
                    Text('Host: ${connection['database_attributes']['host'] ?? 'N/A'}'),
                    Text('Port: ${connection['database_attributes']['port'] ?? 'N/A'}'),
                  ],
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.right_chevron),
                  onPressed: () async {
                    final selectedTables = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => ConnectionTablesPage(
                          databaseName: (connection['database_name'] ?? '').replaceAll(' ', ''),
                        ),
                      ),
                    );

                    if (selectedTables != null) {
                      final deployService = DeployService();
                      final agentId = widget.agentId;

                      final dbConfig = {
                        'data_configs': [
                          {
                            'type': 'database',
                            'db_connection_name': selectedTables['db_connection_name'],
                            'db_table_names': selectedTables['db_table_names'],
                            'db_type': connection['database_type'] ?? 'Unknown',
                          }
                        ]
                      };

                      // Show a dialog indicating deployment has started
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('Deployment'),
                          content: Column(
                            children: [
                              Text('Deployment started...'),
                              CupertinoActivityIndicator(),
                            ],
                          ),
                        ),
                      );

                      try {
                        final response = await deployService.deployHaivaDb(agentId, dbConfig);
                        Navigator.of(context).pop(); // Close the dialog

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          print('Deployment successful');
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Success'),
                              content: Text('Deployment started successfully!'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close success dialog
                                    Navigator.of(context).pop(); // Pop navigation to the previous page
                                  },
                                ),
                              ],
                            ),
                          );
                        } else {
                          print('Deployment failed');
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: Text('Error'),
                              content: Text('Deployment failed. Please try again.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        Navigator.of(context).pop(); // Close the "deployment started" dialog
                        print('Error during deployment: $e');
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: Text('Error'),
                            content: Text('Error during deployment: $e'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
