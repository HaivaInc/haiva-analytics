import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/db_config.dart';
import 'package:haivanalytics/pages/onboard.dart';
import 'package:haivanalytics/providers/workspace_provider.dart';
import 'package:haivanalytics/providers/zoho_provider.dart';
import 'package:haivanalytics/services/auth_service.dart';
import 'package:haivanalytics/statemanagement/chatstate.dart';
import 'package:haivanalytics/theme/colortheme.dart';
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
              ChangeNotifierProvider(create: (context) => ChatProvider()),
              ChangeNotifierProvider(create: (_) => AgentProvider()),
              ChangeNotifierProvider(create: (_) => WorkspaceProvider()),
              ChangeNotifierProvider(create: (_) => ConfigurationProvider()),
              Provider<AuthService>(create: (_) => AuthService()),
            ],
       //      child: CupertinoApp(
       // color: CupertinoDynamicColor.maybeResolve(Colors.deepPurpleAccent, context),
       //        debugShowCheckedModeBanner: false,
       //        title: 'Agent Management',
       //        theme: CupertinoThemeData(
       //              applyThemeToAll: true,
       //
       //
       //               barBackgroundColor: themeColor,
       //          brightness: Brightness.light,
       //          scaffoldBackgroundColor: Colors.grey[50]  ,
       //          primaryColor: themeColor,
       //           textTheme: CupertinoTextThemeData(
       //
       //            navTitleTextStyle: GoogleFonts.raleway(color: Colors.white),
       //            navLargeTitleTextStyle: GoogleFonts.raleway(color: Colors.white),
       //            navActionTextStyle: GoogleFonts.raleway(color: Colors.white),
       //            tabLabelTextStyle: GoogleFonts.raleway(color: Colors.black54),
       //            dateTimePickerTextStyle: GoogleFonts.raleway(color: themeColor),
       //            textStyle: GoogleFonts.raleway(color: Colors.black),
       //            actionTextStyle: GoogleFonts.raleway(color: themeColor),
       //            pickerTextStyle: GoogleFonts.raleway(color: themeColor),
       //         primaryColor: themeColor,
       //
       //          ),
       //
       //
       //        ),
       //        // Set theme mode based on provider
       //        home: OnboardingPage(),
       //      ),
            child: MaterialApp(

              debugShowCheckedModeBanner: false,

              theme: ThemeData(
                // Apply overall theme properties
                useMaterial3: true,
                primaryColor: ColorTheme.primary,
                visualDensity: VisualDensity.adaptivePlatformDensity,
                brightness: Brightness.light,

              scaffoldBackgroundColor: Colors.grey[50],

                // AppBar theme
                appBarTheme: AppBarTheme(
                  color: themeColor, // background color for the AppBar
                  titleTextStyle: GoogleFonts.raleway(color: Colors.white), // Text style for the AppBar title
                ),

                // Text theme for general texts in the app
                textTheme: TextTheme(
                  bodyLarge: GoogleFonts.raleway(color: Colors.black), // General text color
                  bodyMedium: GoogleFonts.raleway(color: Colors.black),
                  labelLarge: GoogleFonts.raleway(color: themeColor), // Text on buttons
                  titleLarge: GoogleFonts.raleway(color: Colors.white), // AppBar title text
                ),

                // Tab bar label styles
                tabBarTheme: TabBarTheme(

                  labelColor: Colors.black54, // Tab label text color
                  unselectedLabelColor: Colors.grey, // Tab unselected text color
                  labelStyle: GoogleFonts.raleway(color: Colors.black54), // Tab label text style
                ),

                // Button theme
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor, // Background color of the button
                    textStyle: GoogleFonts.raleway(color: Colors.white), // Text style for the button
                  ),
                ),

                // Text button theme (e.g. for actions like in AlertDialogs)
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: themeColor, textStyle: GoogleFonts.raleway(color: themeColor), // Text style for action buttons
                  ),
                ),

                // Other elements like DatePicker can be customized similarly
                // Date Picker theme
                inputDecorationTheme: InputDecorationTheme(
                  labelStyle: GoogleFonts.raleway(color: themeColor), // DateTime picker text style
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: themeColor),
                  ),
                ),
              )
,
                home:Consumer<ChatProvider>(
    builder: (context, chatProvider, child) {return OnboardingPage();})
            ),
          );
        },
      ),
    );
  }
}
