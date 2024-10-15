import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/deploy_service.dart';
import '../theme/colortheme.dart';
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
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.primary,
        title: Text('Connections'),
        actions: [CupertinoButton(
          padding:  EdgeInsets.zero,
          onPressed: () {
            final route = CupertinoPageRoute(
              builder: (context) => DatabaseForm(agentId: widget.agentId),
            );
            Navigator.push(context, route);
          },
          child: Padding(
            padding:  EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.add_circled_solid,
              color: Colors.white,
            ),
          ),
        ),],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : _connections.isEmpty
            ? Center(child: Text('No connections found'))
            : ListView.builder(
          itemCount: _connections.length,
          itemBuilder: (context, index) {
            final connection = _connections[index];
            return Container(

              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: ColorTheme.primary.withOpacity(0.2),
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CupertinoListTile(

                title: Text(connection['database_name'] ?? 'Unnamed Database',style:
                TextStyle(fontWeight: FontWeight.bold,
                fontSize: 14,),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${connection['database_type'] ?? 'Unknown'}',
                      style:   TextStyle(
                    fontSize: 12,),),
                    SizedBox(height: 4),
                    // Text('Host: ${connection['database_attributes']['host'] ?? 'N/A'}'),
                    // SizedBox(height: 4),
                    // Text('Port: ${connection['database_attributes']['port'] ?? 'N/A'}'),
                  ],
                ),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(CupertinoIcons.right_chevron,
                  color: ColorTheme.primary,),
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
                      final dbConfig ={
                        "agent_flow":{
                    "flow":  [
                      {
                      "type": "haiva.start",
                      "ports": {
                      "items": [
                      {
                      "group": "in",
                      "id": "611a2b13-0596-4e63-9541-7ea508034ec8"
                      },
                      {
                      "group": "out",
                      "id": "739f2c09-d4d6-47f2-913a-fc6acb9b7452"
                      }
                      ]
                      },
                      "data": {},
                      "id": "73660ff7-6c56-4dc8-a758-3fd9a7050c5e"
                      },
                      {
                      "type": "haiva.welcomemessage",
                      "ports": {
                      "items": [
                      {
                      "group": "in",
                      "id": "fb7a3a8f-436e-42b0-badc-8a4bc3a1cfd5"
                      },
                      {
                      "group": "out",
                      "id": "42ee55e9-d5e1-4878-b68e-18b4cbca3626"
                      }
                      ]
                      },
                      "data": {
                      "textInput": "Hello! from HAIVA. I'm a AI powered agent I can answer your queries."
                      },
                      "id": "a2bc83c6-8b96-4312-be87-7459235efb6c"
                      },
                      {
                      "type": "standard.Link",
                      "source": {
                      "id": "73660ff7-6c56-4dc8-a758-3fd9a7050c5e",
                      "port": "739f2c09-d4d6-47f2-913a-fc6acb9b7452"
                      },
                      "target": {
                      "id": "a2bc83c6-8b96-4312-be87-7459235efb6c",
                      "port": "fb7a3a8f-436e-42b0-badc-8a4bc3a1cfd5"
                      },
                      "id": "42e1dd51-a1bc-4445-87aa-a97a69ab94e3"
                      },
                      {
                      "type": "haiva.useraction",
                      "ports": {
                      "items": [
                      {
                      "group": "in",
                      "id": "7db2205e-f7a1-4c8f-9f05-891939d706cd"
                      },
                      {
                      "group": "out",
                      "id": "dc7d777c-f4a1-488e-ad7e-2bdadf03579c"
                      }
                      ]
                      },
                      "data": {},
                      "id": "51cade5a-10ab-4602-b6ff-df40621708d3"
                      },
                      {
                      "type": "standard.Link",
                      "source": {
                      "id": "a2bc83c6-8b96-4312-be87-7459235efb6c",
                      "port": "42ee55e9-d5e1-4878-b68e-18b4cbca3626"
                      },
                      "target": {
                      "id": "51cade5a-10ab-4602-b6ff-df40621708d3",
                      "port": "7db2205e-f7a1-4c8f-9f05-891939d706cd"
                      },
                      "id": "3bf96b9e-b7f6-4d9c-ba7a-24622f8b57e3"
                      },
                      {
                      "type": "haiva.agentresponse",
                      "ports": {
                      "items": [
                      {
                      "group": "in",
                      "id": "12e80473-73f4-46b5-9956-cd22fb379bf2"
                      },
                      {
                      "group": "out",
                      "id": "6454a221-75ef-478a-8fc4-3707594f026e"
                      }
                      ]
                      },
                      "data": {},
                      "id": "233a9b35-f862-40c4-81fb-50ac4a0838d1"
                      },
                      {
                      "type": "standard.Link",
                      "source": {
                      "id": "51cade5a-10ab-4602-b6ff-df40621708d3",
                      "port": "dc7d777c-f4a1-488e-ad7e-2bdadf03579c"
                      },
                      "target": {
                      "id": "233a9b35-f862-40c4-81fb-50ac4a0838d1",
                      "port": "12e80473-73f4-46b5-9956-cd22fb379bf2"
                      },
                      "id": "bc306c03-b04f-4dc6-aadd-81fbaa514658"
                      },
                      {
                      "type": "standard.Link",
                      "source": {
                      "id": "233a9b35-f862-40c4-81fb-50ac4a0838d1",
                      "port": "6454a221-75ef-478a-8fc4-3707594f026e"
                      },
                      "target": {
                      "id": "51cade5a-10ab-4602-b6ff-df40621708d3",
                      "port": "7db2205e-f7a1-4c8f-9f05-891939d706cd"
                      },
                      "id": "10446fab-f1be-49eb-a2e0-c0b6a69972f3"
                      }
                      ]
                        },
                        "data_configs": [
                          {
                            "category": '',
                            "data_sources":[
                              {
                                "type": "database",
                             "configs": [
                               {
                                 "database_type": connection['database_type'] ?? 'Unknown',
                                 "database_name": selectedTables['db_connection_name'],
                                 "database_objects":[
                                   {
                                     "database_object_type": 'table',
                                     "database_object_list": selectedTables['db_table_names'],
                                   }
                                 ]
                               }
                             ]
                              }
                            ]
                          }
                        ]
                      };

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
                        final savedresponse = await _dbService.saveDbConfig(agentId, dbConfig);

              if(savedresponse.statusCode == 200 || savedresponse.statusCode == 201){
                final response = await deployService.deployHaivaDb(agentId, dbConfig);
                Navigator.of(context).pop(); // Close the dialog

                if (response.statusCode == 200 || response.statusCode == 201) {
                  print('Deployment successful');
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: Text('Success'),
                      content: Text('Deployment successful!'),
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
