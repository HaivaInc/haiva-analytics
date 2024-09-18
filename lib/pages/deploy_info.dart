import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:haivanalytics/theme/colortheme.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

import '../constants.dart';

class DeployInfoPage extends StatefulWidget {
  final String agent;

  const DeployInfoPage({Key? key, required this.agent}) : super(key: key);

  @override
  State<DeployInfoPage> createState() => _DeployInfoPageState();
}

class _DeployInfoPageState extends State<DeployInfoPage> {
  int _selectedSegment = 0;
  bool _isGeneratingAPK = false;
  bool _isAPKAvailable = false;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Deploy Info'),
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
                     children: [ CupertinoActivityIndicator(
        animating: true,
        radius: 20,
      ),
                     SizedBox(height: 10),
                     Text("This May Take Up To 5 Minutes",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)],
                   )
                  else
                    CupertinoButton(
color: ColorTheme.primary,
                      disabledColor: ColorTheme.secondary,

                      onPressed: _generateAPK,
                      child: Text('Generate APK'),
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

  Widget _buildSegmentedControl() {
    return CupertinoSegmentedControl<int>(
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

  Future<void> _generateAPK() async {
    setState(() {
      _isGeneratingAPK = true;
      _isError = false;
    });

    try {
      // Trigger APK build
      final response = await http.post(
        Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/trigger-apk-creation'),
        body: {
          'workspaceId': Constants.workspaceId,
          'agentId': widget.agent
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201)  {
        // Check APK availability
        Timer.periodic(Duration(seconds: 30), (timer) async {
          final checkResponse = await http.get(
            Uri.parse('https://app-haiva.gateway.apiplatform.io/v1/check-apk-availability?workspaceId=${Constants.workspaceId}&agentId=${widget.agent}'),
            headers: {
              'Authorization': 'Bearer ${Constants.accessToken}',
            },
          );

          if (checkResponse.statusCode == 200) {
            final data = json.decode(checkResponse.body);
            final bool isAvailable = data['isAvailable'] ?? false;
            print("isAvailable: $isAvailable");

            if (isAvailable) {
              timer.cancel();
              setState(() {
                _isAPKAvailable = true;
                _isGeneratingAPK = false;
              });
            }
          } else {
            timer.cancel();
            setState(() {
              _isError = true;
              _isGeneratingAPK = false;
            });
          }
        });

      } else {
        setState(() {
          _isError = true;
          _isGeneratingAPK = false;
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _isGeneratingAPK = false;
      });
    }
  }

  void _handleAPKDownload() {
    final fileUrl = 'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-release-apks/${widget.agent}/app-release.apk';
    // Download APK file using `url_launcher` package or any download library
  }

  void _handleAPKQR() {
    final qrData = 'https://s3.amazonaws.com/haiva.apiplatform.io/haiva-release-apks/${widget.agent}/app-release.apk';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('APK QR Code'),
        content: QrImageView(
          data: qrData,
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
