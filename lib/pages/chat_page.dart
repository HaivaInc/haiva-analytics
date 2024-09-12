import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatPage extends StatefulWidget {
  final String agentId;

  const ChatPage({Key? key, required this.agentId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _controller = WebViewController()

      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse('https://agent.haiva.ai/${widget.agentId}'));
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(); // Pop ChatPage and go back to MainNavigationPage
    return false; // Prevent the default back action
  }
  Future<void> _requestPermissions() async {
    PermissionStatus microphonePermission = await Permission.microphone.request();
    PermissionStatus cameraPermission = await Permission.camera.request();

    if (microphonePermission.isGranted && cameraPermission.isGranted) {
      // Permissions are granted, proceed
    } else if (microphonePermission.isDenied || cameraPermission.isDenied) {
      // You can show a dialog explaining the need for these permissions
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  true,
      child: SafeArea(
        child: CupertinoPageScaffold(
          backgroundColor: CupertinoColors.white,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }

}

