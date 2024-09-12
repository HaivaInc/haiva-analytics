import 'package:flutter/cupertino.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/zoho_config.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../services/auth_service.dart';
import 'agent_select_page.dart';
import 'login.dart';
import 'nav_page.dart';

class OnboardingPage extends StatelessWidget {

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return CupertinoPageScaffold(
      backgroundColor: Color(0xFF19437D),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Icon at the top
              Padding(
                padding: const EdgeInsets.fromLTRB(0,50,0,0),
                child: Icon(
                  CupertinoIcons.graph_circle_fill,
                  size: 50,
                  color: CupertinoColors.white,
                ),
              ),
              // Expanded widget to center the image carousel
              Expanded(
                child: CarouselSlider(

                  options: CarouselOptions(

                    enlargeCenterPage: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    viewportFraction: 0.8,
                  ),
                  items: [1,2,3,4,5,6].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,

                            boxShadow:[BoxShadow(color: Colors.white, spreadRadius: 10, blurRadius: 0, offset: Offset(2, 3)),],
                            image: DecorationImage(
                              image: AssetImage('assets/images/onboarding_$i.png'), // Replace with your image assets
scale: 1.0,
                              filterQuality: FilterQuality.high
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              // Bottom text and button
              SizedBox(height: 20),
              Text(
                'Welcome to HAIVA Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: GoogleFonts.raleway().fontFamily,
                  fontSize: 28,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Your Journey Starts Here',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 18,
                  color: CupertinoColors.opaqueSeparator,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CupertinoButton(
color: Colors.white,
                child: Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16,color: Color(0xFF19437D), fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  await authService.login();
                  if (await authService.isAuthenticated() ) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                      //  builder: (context) => MainNavigationPage(),
                        builder: (context) => AgentSelectionPage(),
                      ),
                    );
                  }
                },
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                borderRadius: BorderRadius.circular(20),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
