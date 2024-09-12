import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/db_config.dart';
import 'package:haivanalytics/pages/onboard.dart';
import 'package:haivanalytics/providers/workspace_provider.dart';
import 'package:haivanalytics/providers/zoho_provider.dart';
import 'package:haivanalytics/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'providers/agent_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Color themeColor = Color(0xFF19437D);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AgentProvider(),
      child: Consumer<AgentProvider>(
        builder: (context, agentProvider, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
              ChangeNotifierProvider(create: (_) => ConfigurationProvider()),
              Provider<AuthService>(create: (_) => AuthService()),
            ],
            child: CupertinoApp(
       color: CupertinoDynamicColor.maybeResolve(Colors.deepPurpleAccent, context),
              debugShowCheckedModeBanner: false,
              title: 'Agent Management',
              theme: CupertinoThemeData(
                    applyThemeToAll: true,


                     barBackgroundColor: themeColor,
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.grey[50]  ,
                primaryColor: themeColor,
                 textTheme: CupertinoTextThemeData(

                  navTitleTextStyle: GoogleFonts.raleway(color: Colors.white),
                  navLargeTitleTextStyle: GoogleFonts.raleway(color: Colors.white),
                  navActionTextStyle: GoogleFonts.raleway(color: Colors.white),
                  tabLabelTextStyle: GoogleFonts.raleway(color: Colors.black54),
                  dateTimePickerTextStyle: GoogleFonts.raleway(color: themeColor),
                  textStyle: GoogleFonts.raleway(color: Colors.black),
                  actionTextStyle: GoogleFonts.raleway(color: themeColor),
                  pickerTextStyle: GoogleFonts.raleway(color: themeColor),
               primaryColor: themeColor,

                ),


              ),
              // Set theme mode based on provider
              home: OnboardingPage(),
            ),
          );
        },
      ),
    );
  }
}
