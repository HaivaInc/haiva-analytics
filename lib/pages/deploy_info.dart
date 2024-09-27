import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/theme/colortheme.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

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
  @override
  bool get wantKeepAlive => true; // Keeps state when navigating

  @override
  void initState() {
    super.initState();
    _loadState();
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
                        Text("This May Take Up To 5 Minutes",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    );
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
