import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/pages/publish_agent.dart';
import 'package:haivanalytics/theme/colortheme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../services/agent_service.dart';

class DeployInfoPage extends StatefulWidget {
  final String agent;

  const DeployInfoPage({Key? key, required this.agent}) : super(key: key);

  @override
  State<DeployInfoPage> createState() => _DeployInfoPageState();
}

class _DeployInfoPageState extends State<DeployInfoPage> with AutomaticKeepAliveClientMixin {
  int _selectedSegment = 0;
  bool _isGeneratingAPK = false;
  bool _isAPKAvailable = false;
  bool _isError = false;
  Timer? _apkCheckTimer;
  int _apkCheckCounter = 0;
  String _apkFileUrl = '';
  int _countdown = 300;
  Agent? agent;
  bool _isLoading = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadAgentDetails();
    _loadState();
  }

  Future<void> _loadAgentDetails() async {
    final agentProvider = Provider.of<AgentProvider>(context, listen: false);
    agent = await agentProvider.getAgentById(widget.agent);
    setState(() {});
  }

  @override
  void dispose() {
    _apkCheckTimer?.cancel(); // Ensure timer is cancelled on dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.primary,
        title: Text('Deploy Info'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      _buildSegmentedControl(),
                      SizedBox(height: 20),
                      _buildSelectedContent(),
                      if (_selectedSegment == 1) ...[
                        if (_isGeneratingAPK)
                          Column(
                            children: [
                              CupertinoActivityIndicator(animating: true, radius: 20),
                              SizedBox(height: 10),
                              Text(
                                "This May Take Up To 5 Minutes",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        else
                          CupertinoButton(
                            color: ColorTheme.primary,
                            disabledColor: ColorTheme.secondary,
                            onPressed: _isAPKAvailable ? null : _generateAPK,
                            child: Text(_isAPKAvailable ? 'APK Available' : 'Generate APK'),
                          ),
                        if (_isAPKAvailable)
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _handleAPKDownload,
                                child: Text('Download APK'),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _handleAPKQR,
                                child: Text('Show APK QR Code'),
                              ),
                            ],
                          ),
                        if (_isError)
                          Text(
                            'Error in APK Generation',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Full-width button at the bottom of the screen
            if ((agent?.isDeployed ?? false) && (agent?.is_published == false))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Confirm Publish'),
                            content: Column(
                              children: [
                                SizedBox(height: 5),
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Publishing will make this agent available in the Haiva Marketplace! ',
                                          style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                        ),
                                        TextSpan(
                                          text: 'Haiva Agent Hub',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF19437D),
                                            decoration: TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launch('https://haiva.ai/agent-hub');
                                            },
                                        ),
                                        TextSpan(
                                          text: ', accessible to all users within the Haiva ecosystem.',
                                          style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Proceed to publish this agent?',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),

                            actions: [
                              CupertinoDialogAction(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Confirm'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PublishAgentPage(agent?.id)),
                                  );
                                },
                                isDestructiveAction: false,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'Publish to Agent Hub',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if ((agent?.is_published ?? false) && (agent?.is_featured == false))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Confirm Unpublish'),
                            content: Text('Are you sure you want to unpublish this agent from the Agent Hub?'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Unpublish'),
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  _unpublishToHub(agent?.id); // Call the unpublish method
                                },
                                isDestructiveAction: true,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.primary,
                    ),
                    child: Text(
                      'Unpublish from Agent Hub',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if ((agent?.is_published ?? false) && (agent?.is_featured == false))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Confirm Feature'),
                            content: Text('Are you sure you want to mark this agent as a Featured Agent?'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Feature'),
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  _featureAgent(agent?.id); // Call the feature method
                                },
                                isDestructiveAction: false,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.primary,
                    ),
                    child: Text(
                      'Mark as Featured Agent',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (agent?.is_featured ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                            title: Text('Confirm Unfeature'),
                            content: Text('Are you sure you want to unmark this agent as a Featured Agent?'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: Text('Unfeature'),
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  _DefeatureAgent(agent?.id); // Call the defeature method
                                },
                                isDestructiveAction: true,
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.primary,
                    ),
                    child: Text(
                      'Unmark as Featured Agent',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _publishToHub(String? agentID) async {
    try {
      final agentService = AgentService();
      final response = await agentService.publishAgent(agentID!);
      Map<String, dynamic> res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Agent published successfully')),
        );
        _loadAgentDetails();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to publish agent')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  Future<void> _unpublishToHub(String? agentID) async {
    try {
      final agentService = AgentService();
      final response = await agentService.unPublishAgent(agentID!);
      Map<String, dynamic> res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Agent unpublished successfully')),
        );
        _loadAgentDetails();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to unpublish agent')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  Future<void> _featureAgent(String? agentID) async {
    try {
      final agentService = AgentService();
      final response = await agentService.featureAgent(agentID!);
      Map<String, dynamic> res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Agent successfully featured')),
        );
        _loadAgentDetails();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to feature agent')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _DefeatureAgent(String? agentID) async {
    try {
      final agentService = AgentService();
      final response = await agentService.DefeatureAgent(agentID!);
      Map<String, dynamic> res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Agent successfully unfeatured')),
        );
        _loadAgentDetails();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to unfeature agent')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _generateAPK() async {
    setState(() {
      _isGeneratingAPK = true;
      _isError = false;
    });
    _saveState();

    try {
      final response = await http.post(
        Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/trigger-apk-creation'),
        body: {
          'workspaceId': Constants.workspaceId,
          'agentId': widget.agent,
        },
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print(responseData);
        if (responseData['buildStarted'] == true) {
          print(" build started :true");
          _startAPKCheckTimer();
        } else {
          _handleError();
        }
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }


// 5 minutes in seconds

  void _startAPKCheckTimer() {
    _apkCheckCounter = 0;
    _apkCheckTimer?.cancel();
    _apkCheckTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_countdown > 0) {
        setState(() {
          _countdown--;  // Decrease countdown
        });
      }

      if (_apkCheckCounter >= 10 || _countdown <= 0) {
        _handleError();
        timer.cancel();
        return;
      }

      // The APK availability check every 30 seconds
      if (_apkCheckCounter % 30 == 0) {
        _apkCheckCounter++;

        try {
          final checkResponse = await http.get(
            Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/check-apk-availability?workspaceId=${Constants.workspaceId}&agentId=${widget.agent}'),
            headers: {
              'Authorization': 'Bearer ${Constants.accessToken}',
            },
          );
          print("check status = ${checkResponse.statusCode}");
          if (checkResponse.statusCode == 200) {

            print("check response = ${checkResponse.body}");
            final data = json.decode(checkResponse.body);
            final bool isAvailable = data['isAvailable'] ?? false;

            if (isAvailable) {
              print("is available");
              timer.cancel();
              setState(() {
                _isAPKAvailable = true;
                _isGeneratingAPK = false;
                _apkFileUrl = 'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-release-apks/${widget.agent}/app-release.apk';
              });
              _saveState();
            }
          } else {
            _handleError();
          }
        } catch (e) {
          _handleError();
        }
      }
    });
  }




  void _handleError() {
    _apkCheckTimer?.cancel();
    setState(() {
      _isError = true;
      _isGeneratingAPK = false;
    });
    _saveState();
  }

  Future<void> _loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGeneratingAPK = prefs.getBool('isGeneratingAPK_${widget.agent}') ?? false;
      _isAPKAvailable = prefs.getBool('isAPKAvailable_${widget.agent}') ?? false;
      _isError = prefs.getBool('isError_${widget.agent}') ?? false;
      _apkFileUrl = prefs.getString('apkFileUrl_${widget.agent}') ?? '';
    });
  }

  Future<void> _saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isGeneratingAPK_${widget.agent}', _isGeneratingAPK);
    prefs.setBool('isAPKAvailable_${widget.agent}', _isAPKAvailable);
    prefs.setBool('isError_${widget.agent}', _isError);
    prefs.setString('apkFileUrl_${widget.agent}', _apkFileUrl);
  }


  void _handleAPKDownload() {
    if (_apkFileUrl.isNotEmpty) {
      // Implement the download logic here
      // You might want to use a package like url_launcher to open the URL in a browser
      // or implement a proper file download mechanism
      print('Downloading APK from: $_apkFileUrl');
    }
  }

  void _handleAPKQR() {
    if (_apkFileUrl.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('APK QR Code'),
          content: QrImageView(
            data: _apkFileUrl,
            version: QrVersions.auto,
            size: 200.0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSegmentedControl() {
    return CupertinoSegmentedControl<int>(
      pressedColor: ColorTheme.primary,
      selectedColor: ColorTheme.primary,
      borderColor:  ColorTheme.primary,
      children: {
        0: Padding(
          padding: EdgeInsets.all(8),
          child: Text('Web Tagging'),
        ),
        1: Padding(
          padding: EdgeInsets.all(8),
          child: Text('Android'),
        ),
      },
      onValueChanged: (int value) {
        setState(() {
          _selectedSegment = value;
        });
      },
      groupValue: _selectedSegment,
    );
  }

  Widget _buildSelectedContent() {
    if (_selectedSegment == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Web Tagging Script',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('Copy the HTML code provided below and insert it immediately before the closing </body> tag on each page where you want the chat widget to be displayed.' ,style: TextStyle(fontSize: 12, ),),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              '<script src="https://agent.haiva.ai/js/script.js" '
                  'data-agent-id="${widget.agent}"></script>',
              style: TextStyle(color: CupertinoColors.activeGreen, fontFamily: 'Courier', fontSize: 12),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
          ),
          SizedBox(height: 20),
        ],
      );
    }
  }
}
