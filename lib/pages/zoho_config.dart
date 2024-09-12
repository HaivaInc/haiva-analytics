import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/pages/talk_page.dart';
import 'package:provider/provider.dart';
import '../providers/zoho_provider.dart';

class ZohoConfigurePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Configure Zoho Inventory'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ConfigurationProvider>(
                builder: (context, config, child) {
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      CupertinoTextField(
                        clearButtonMode: OverlayVisibilityMode.always,
                        placeholder: 'Name of the Connector',
                        onChanged: (value) => config.setConnectorName(value),
                      ),
                      SizedBox(height: 16),
                      CupertinoFormRow(
                        child: CupertinoSlidingSegmentedControl<String>(
                          backgroundColor: Colors.white10,
                          groupValue: config.authType,
                          children: {
                            'OAuth2.0': Text('OAuth2.0'),
                            'Bearer Token': Text('Bearer Token'),
                          },
                          onValueChanged: (value) => config.setAuthType(value!),
                        ),
                        prefix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Authorization Type'),
                        ),
                      ),
                      SizedBox(height: 16),
                      if (config.authType == 'Bearer Token')
                        CupertinoTextField(
                          placeholder: 'Token',
                          onChanged: (value) => config.setToken(value),
                        ),
                      if (config.authType == 'OAuth2.0') ...[
                        CupertinoTextField(
                          placeholder: 'Authorize URL',
                          onChanged: (value) => config.setAuthorizeUrl(value),
                        ),
                        SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: 'Access Token URL',
                          onChanged: (value) => config.setAccessTokenUrl(value),
                        ),
                        SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: 'Refresh Token URL',
                          onChanged: (value) => config.setRefreshTokenUrl(value),
                        ),
                        SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: 'Client ID',
                          onChanged: (value) => config.setClientId(value),
                        ),
                        SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: 'Client Secret',
                          onChanged: (value) => config.setClientSecret(value),
                        ),
                        SizedBox(height: 16),
                        CupertinoTextField(
                          placeholder: 'Scope',
                          onChanged: (value) => config.setScope(value),
                        ),
                      ],
                      SizedBox(height: 32),
                      CupertinoButton.filled(
                        child: Text('Configure'),
                        onPressed: () async {
                          var (success, message) = await config.configure();
                          if (success) {
                            _showSuccessModal(context);
                          } else {
                            _showErrorModal(context, message);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Container(
              constraints: BoxConstraints(
                maxWidth: double.infinity,
                minHeight: 100,
                maxHeight: 200,

              ),
              child: Image.asset(
                'assets/images/Dog.png',
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSuccessModal(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(

      title: Text('Configuration Successful',style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
      message: Column(

        children: [
          Icon(CupertinoIcons.checkmark_circle_fill, color: CupertinoColors.activeGreen, size: 60),
          SizedBox(height: 10),
          Text('Your Zoho Inventory has been configured successfully.',style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(

          child: Text('Proceed',style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                builder: (context) => TalkPage(agentId: '',),
            ),
            );
          },
        ),
      ],
    ),
  );
}

void _showErrorModal(BuildContext context, String errorMessage) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text('Configuration Failed',style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
      message: Column(
        children: [
          Icon(CupertinoIcons.xmark_circle_fill, color: CupertinoColors.destructiveRed, size: 60),
          SizedBox(height: 10),
          Text(errorMessage),
        ],
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text('OK',style: TextStyle(fontFamily: GoogleFonts.raleway().fontFamily),),
          onPressed: () {
        //    Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => TalkPage(agentId: '',),
              ),
            );
          },
        ),
      ],
    ),
  );
}
