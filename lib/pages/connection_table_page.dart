import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';

class ConnectionTablesPage extends StatefulWidget {
  final String databaseName;

  const ConnectionTablesPage({
    Key? key,
    required this.databaseName,
  }) : super(key: key);

  @override
  _ConnectionTablesPageState createState() => _ConnectionTablesPageState();
}

class _ConnectionTablesPageState extends State<ConnectionTablesPage> {
  final DbService _dbService = DbService();
  List<String> _tables = [];
  Set<String> _selectedTables = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    try {
      final response = await _dbService.getDatabaseTables(
        widget.databaseName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        print("response table= ${response.body}");
        setState(() {
          _tables = List<String>.from(data);
          print("tables = ${_tables}");
          _isLoading = false;
        });
      } else {
        print('Error status code: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw Exception('Failed to load tables');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch tables: ${e.toString()}'),
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

  void _toggleTableSelection(String table) {
    setState(() {
      if (_selectedTables.contains(table)) {
        _selectedTables.remove(table);
      } else {
        _selectedTables.add(table);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Tables in ${widget.databaseName}'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Done'),
          onPressed: _selectedTables.isNotEmpty
              ? () {
            // Handle the selected tables here
            print('Selected tables: $_selectedTables');
            Navigator.of(context).pop(_selectedTables.toList());
          }
              : null,
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : _tables.isEmpty
            ? Center(child: Text('No tables found'))
            : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                            itemCount: _tables.length,
                            itemBuilder: (context, index) {
                  final table = _tables[index];
                  final isSelected = _selectedTables.contains(table);
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
                      title: Text(table),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: isSelected
                            ? Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.activeBlue)
                            : Icon(CupertinoIcons.circle, color: CupertinoColors.inactiveGray),
                        onPressed: () => _toggleTableSelection(table),
                      ),
                      onTap: () => _toggleTableSelection(table),
                    ),
                  );
                            },
                          ),
                ),
                Container(
                  child:CupertinoButton(
                    onPressed: _selectedTables.isNotEmpty
                        ? () {

                      Navigator.of(context).pop({
                        'db_connection_name': widget.databaseName,
                        'db_table_names': _selectedTables.toList(),
                      });
                    }
                        : null,
                    child: Text('Save Changes'),
                    color: Color(0xFF19437D),
                  ),
                    )
              ],
            ),
      ),
    );
  }
}