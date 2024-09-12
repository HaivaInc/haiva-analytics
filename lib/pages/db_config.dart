import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'connection_page.dart';

class DatabaseForm extends StatefulWidget {
  final String agentId;
  const DatabaseForm({Key? key, required this.agentId}) : super(key: key);
  @override
  _DatabaseFormState createState() => _DatabaseFormState();
}

class _DatabaseFormState extends State<DatabaseForm> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DbService();
  final TextEditingController _dbNameController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _databaseNameController = TextEditingController();

  String _databaseType = 'mysql';
  bool _isLoading = false;
  bool _passwordVisible = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _dbService.insertDatabaseConnection(
          dbName: _dbNameController.text,
          host: _hostController.text,
          password: _passwordController.text,
          port: _portController.text,
          username: _usernameController.text,
          databaseName: _databaseNameController.text,
          databaseType: _databaseType,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => ConnectionsPage(agentId: widget.agentId,),
            ),
          );
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Success'),
              content: Text('Database connection added successfully.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          // Handle error response
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: Text('Error'),
              content: Text('Failed to add database connection. Please try again.'),
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
        // Handle exceptions
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        prefix: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(icon, color: CupertinoColors.systemGrey),
        ),
        suffix: isPassword
            ? Padding(
          padding: EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            child: Icon(
              _passwordVisible ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
              color: CupertinoColors.systemGrey,
            ),
          ),
        )
            : null,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        obscureText: isPassword && !_passwordVisible,
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Database Connection'),
      ),
      child: SafeArea(
        child: _isLoading
            ? Center(child: CupertinoActivityIndicator())
            : CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        controller: _databaseNameController,
                        placeholder: 'Database Name',
                        icon: CupertinoIcons.doc_text,
                      ),
                      _buildTextField(
                        controller: _dbNameController,
                        placeholder: 'DB Name',
                        icon: CupertinoIcons.text_badge_checkmark,
                      ),
                      _buildTextField(
                        controller: _hostController,
                        placeholder: 'Host',
                        icon: CupertinoIcons.globe,
                      ),
                      _buildTextField(
                        controller: _portController,
                        placeholder: 'Port',
                        icon: CupertinoIcons.number,
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        controller: _usernameController,
                        placeholder: 'Username',
                        icon: CupertinoIcons.person,
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        icon: CupertinoIcons.lock,
                        isPassword: true,
                      ),
                      SizedBox(height: 16),
                      CupertinoSegmentedControl<String>(
                        children: {
                          'mysql': Text('MySQL', style: TextStyle(fontSize: 10)),
                          'postgresql': Text('POSTGRESQL', style: TextStyle(fontSize: 10)),
                          'mysqlserver': Text('MS SQLSERVER', style: TextStyle(fontSize: 10)),
                        },
                        onValueChanged: (value) {
                          setState(() {
                            _databaseType = value;
                          });
                        },
                        groupValue: _databaseType,
                      ),
                      SizedBox(height: 24),
                      CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(8),
                        child: Text('Submit'),
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}