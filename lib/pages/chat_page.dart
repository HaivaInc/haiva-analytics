// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
//
// class ChatPage extends StatefulWidget {
//   final String agentId;
//   const ChatPage({Key? key, required this.agentId}) : super(key: key);
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin {
//   late WebViewController _controller;
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {},
//           onPageStarted: (String url) {},
//           onPageFinished: (String url) {},
//           onWebResourceError: (WebResourceError error) {
//             print(error.toString());
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://agent.haiva.ai/${widget.agentId}'));
//
//     if (_controller.platform is AndroidWebViewController) {
//       AndroidWebViewController.enableDebugging(true);
//       (_controller.platform as AndroidWebViewController)
//           .setMediaPlaybackRequiresUserGesture(false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     return WillPopScope(
//       onWillPop: () async => true,
//       child: SafeArea(
//         child: CupertinoPageScaffold(
//           backgroundColor: CupertinoColors.white,
//           child: GestureDetector(
//             onVerticalDragUpdate: (details) {
//               // Optional: Adjust the scrolling sensitivity
//               double delta = details.primaryDelta ?? 0;
//               if (delta < 0) {
//                 _controller.scrollBy(0, -delta.toInt()); // Scroll down
//               } else {
//                 _controller.scrollBy(0, delta.toInt()); // Scroll up
//               }
//             },
//             child: WebViewWidget(
//               controller: _controller,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
