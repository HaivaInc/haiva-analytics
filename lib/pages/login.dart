import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import Material for gradient and other styling
import 'package:haivanalytics/pages/nav_page.dart';
import 'package:provider/provider.dart';
import '../providers/workspace_provider.dart';
import '../services/auth_service.dart';
import '../services/workspace_id_service.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Background image

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF19437D).withOpacity(0.5), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or illustration at the top
                Image.asset(
                  'assets/haiva.png', // Add your logo or an illustration
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                // Login button
                CupertinoButton(
                  color: Color(0xFF19437D),
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () async {
                    await authService.login();
                    if (await authService.isAuthenticated()) {
                      // Navigator.push(
                      //   context,
                      //   CupertinoPageRoute(
                      //     builder: (context) => MainNavigationPage(),
                      //   ),
                      // );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    child: Text(
                      'Login with HAIVA',
                      style: TextStyle(fontSize: 18, color: CupertinoColors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
