import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../theme/colortheme.dart';
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
String ? _errorMessage;
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
    bool isConnectorName = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: TextStyle(color: CupertinoColors.placeholderText),
            prefix: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(icon, color: Color(0xFF19437D)),
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
            onChanged: (value) {
              if (isConnectorName) {
                setState(() {
                  if (value.contains(' ')) {
                    _errorMessage = 'Connection name cannot contain spaces.';
                  } else {
                    _errorMessage = null;
                  }
                });
              }
            },
          ),
        ),
        if (isConnectorName && _errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.primary,
        title: Text('Database Connection'),
      ),
      body: SafeArea(
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

                      CupertinoSegmentedControl<String>(
                        selectedColor: ColorTheme.primary,
                        borderColor: ColorTheme.primary,
                        children: {
                          'mysql': Text('MySQL', style: TextStyle(fontSize: 10)),
                          'postgresql': Text('POSTGRESQL', style: TextStyle(fontSize: 10)),
                          'sqlserver': Text('MS SQLSERVER', style: TextStyle(fontSize: 10)),
                        },
                        onValueChanged: (value) {
                          setState(() {
                            _databaseType = value;
                          });
                        },
                        groupValue: _databaseType,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _databaseNameController,
                        placeholder: 'Connection Name',
                        icon: CupertinoIcons.doc_text,
                        isConnectorName: true,
                      ),

                      _buildTextField(
                        controller: _dbNameController,
                        placeholder: 'Database Name',
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

                      SizedBox(height: 24),
                      CupertinoButton(
                        color: ColorTheme.primary,
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