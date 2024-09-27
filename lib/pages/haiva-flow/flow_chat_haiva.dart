import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../model_chat/responsemsg.dart';
import '../../model_chat/welcomemessage.dart';
import '../../services/haivaservice.dart';
import '../../statemanagement/chatstate.dart';
import '../../theme/colortheme.dart';
import '../../widget/bubble.dart';
import '../agent_select_page.dart';
import 'chatbubble_haiva.dart';


class HaivaChatScreen extends StatefulWidget {
  final String agentId;

  HaivaChatScreen({super.key, required this.agentId });
  @override  HaivaChatScreenState createState() => HaivaChatScreenState();
}

class HaivaChatScreenState extends State<HaivaChatScreen> {
  late ConfettiController _confettiController;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _speechListening = false;
  bool stopSpeaking = false;
  String _lastWords = '';
  bool _isclicked = false;
  bool  isSpeaking =true ;
  final TextEditingController _controller = TextEditingController();
  late List<ResponseMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();// Set to true by default since this screen is for agent messages
  List<LocaleName> _localeNames = [
    LocaleName('en-US', 'English (United States)'),
    LocaleName('es-ES', 'Spanish (Spain)'),
    LocaleName('fr-FR', 'French (France)'),
    LocaleName('de-DE', 'German (Germany)'),
    LocaleName('hi-IN', 'Hindi (India)'),
    LocaleName('ta-IN', 'Tamil (India)'),
    LocaleName('te-IN', 'Telugu (India)'),
    LocaleName('ml-IN', 'Malayalam (India)'),
    LocaleName('kn-IN', 'Kannada (India)'),
    LocaleName('zh-CN', 'Chinese (Simplified)'),
    LocaleName('ja-JP', 'Japanese (Japan)'),
  ];
  String _currentLocaleId = 'en-US';

  bool _isloading = false;
  List<WelcomeMessageData> welcomeMessages = [];
  WelcomeMessageData welcomemessagedata = WelcomeMessageData(type: 'null', data: {});
  List _sampleQuestions =[];
  bool _isWelcomeVisible = true;
  bool _isOnline = false;
  String? _agentName;
  String? _sessionId;
  String? _prevMessage;
  late Timer _timer;
  int _currentIndex = 0;
  final List<String> _loadingStates = [
    "is thinking",
    "is fetching data",
    "is analyzing",
    "is processing"
  ];
  void checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _initSpeech();
    _startLoading();
    sendMessage("hi", displayMessage: false);

    ColorTheme.generateColorsFromAgent(widget.agentId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.setAgentId(widget.agentId);
      chatProvider.fetchAgentDetails();
    });
    _controller.addListener(() {

      // if (_controller.text.isNotEmpty && _componentType=='screen') {
      //   setState(() {
      //     _componentType  ;
      //   });
      // }
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    _localeNames = await _speechToText.locales();
    setState(() {});
  }
  void _startLoading() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _loadingStates.length;
      });
    });
  }
  void _startListening() async {

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: Duration(seconds: 3000),
      pauseFor: Duration(seconds: 300),
      localeId: _currentLocaleId,


    );
    setState(() {
      _speechListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _speechListening = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _controller.text = _lastWords;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });

    if (result.finalResult) {
      _stopListening();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose(); // Dispose the ConfettiController

    _scrollController.dispose();
    super.dispose();
  }


  void sendMessage(String text,
      {bool displayMessage = true,
        bool action = false,
        String? session_id = null,
        String? language,
        dynamic payload}) async {

    _confettiController.play(); // Start confetti animation


    String? previousText = ''; // Store previously sent text here, if available

    String textToSend = text ?? previousText;
    _scrollToBottom();
    if (text.trim().isEmpty) return;
    if (textToSend == null || textToSend.isEmpty) {
      //    print('No text available to send.');
      return;
    }
    if (displayMessage) {
      final userMessage = ResponseMessage(
        MessageType.user,
        DateTime.now(),
        text: text,
      );

      setState(() {
        _messages.add(userMessage);
        _isloading = true;  // Set loading to true
      });
      _controller.clear();
      _scrollToBottom();
    }

    final loadingMessage = ResponseMessage(
      MessageType.bot,
      DateTime.now(),
      customWidget: BubbleWidget(
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _agentName ??'HAIVA ',
              style: GoogleFonts.questrial(
                color: ColorTheme.accent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              " ${_loadingStates[_currentIndex]}",
              style: GoogleFonts.questrial(
                color: ColorTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8), // Spacing between text and loader
            Container(
              width: 15,
              height: 10,
              child: SpinKitThreeBounce(
                color: ColorTheme.primary,
                size: 10,
              ),
            ),
          ],
        ),
      ),
    );
    setState(() {
      _messages.add(loadingMessage);
    });
    String? finalTextToSend = text ?? _prevMessage;
    try {
      Map<String, dynamic>? formData;
      if (payload != null && payload is Map<String, dynamic>) {
        formData = payload;
      }
      final responseMessage = await HaivaService().haivaMessage(
        text,
        widget.agentId,
        isMarkdown: true,
        isButtonClicked: action,
        sessionId: _sessionId,
        language:_currentLocaleId,
        //  payloadType: 'form',
        payloadType: formData != null ? 'form' : 'text',
        formData: payload is Map<String, dynamic> ? payload : null,

      );

      setState(() {
        _sessionId = responseMessage.sessionId;
        _messages.removeLast();
        if(responseMessage.statusCode == 200){
          setState(() {
            _isOnline = true;
          });
        }
        else{
          setState(() {
            _isOnline = false;
          });
        }
        if (responseMessage.haivaMessage != null && responseMessage.haivaMessage!['welcomeMessage'] is List<dynamic>) {
          List<dynamic> welcomeMessagesList = responseMessage.haivaMessage!['welcomeMessage'] as List<dynamic>;

          welcomeMessages.clear(); // Clear previous messages
          for (var item in welcomeMessagesList) {
            if (item is Map<String, dynamic>) {
              WelcomeMessageData messageData = WelcomeMessageData.fromJson(item);
              welcomeMessages.add(messageData);
            }
          }
          if (welcomeMessages.isNotEmpty) {
            welcomemessagedata = welcomeMessages.first; // Set the first welcome message data
          }
        }
        _messages.add(responseMessage);

        _isloading = false;
        _sampleQuestions = responseMessage.haivaMessage?['showCustomQuestions']?['sampleQuestions'];
      });



    } catch (e) {
      //  print("Error: $e");
      setState(() {
        _isloading = false; // Ensure loading state is reset on error
      });
    }


  }




  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



  void _refreshChat() {
    setState(() {

      _messages.clear();
      _isWelcomeVisible = true;
      sendMessage('hi', displayMessage: false,session_id: _sessionId=null,language:_currentLocaleId); // Reset the question clicked state
    });
  }
  void _showRefreshAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorTheme.primary,
          title: Text('Refresh Chat', style: TextStyle(color: ColorTheme.secondary)),
          content: Text('Do you want to refresh the chat?', style: TextStyle(color: ColorTheme.secondary,fontSize: 16)),
          actions: <Widget>[
            OutlinedButton(
              child: Text('No', style: TextStyle(color: ColorTheme.secondary,fontSize: 14)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            OutlinedButton(
              child: Text('Yes', style: TextStyle(color: ColorTheme.secondary,fontSize: 14)),
              onPressed: () {
                // Implement refresh logic here
                _refreshChat();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Mapping of locale identifiers to language names
  final Map<String, String> languageNames = {
    'en-US': 'English (United States)',
    'es-ES': 'Spanish (Spain)',
    'fr-FR': 'French (France)',
    'de-DE': 'German (Germany)',
    'hi-IN': 'Hindi (India)',
    'ta-IN': 'Tamil (India)',
    'te-IN': 'Telugu (India)',
    'ml-IN': 'Malayalam (India)',
    'kn-IN': 'Kannada (India)',
    'zh-CN': 'Chinese (Simplified)',
    'ja-JP': 'Japanese (Japan)',
    // Add more mappings as needed
  };

// Mapping of language codes to their respective names
  final Map<String, String> languageCodeToName = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'kn': 'Kannada',
    'zh': 'Chinese',
    'ja': 'Japanese',
    // Add more mappings as needed
  };



// Extract the language code from a locale identifier
  String _extractLanguageCode(String localeIdentifier) {
    return localeIdentifier.split('-')[0]; // Assumes locale format is language-region
  }

  List<PopupMenuEntry<String>> _buildLanguageMenuItems(List<String> localeIdentifiers) {
    return localeIdentifiers.map((localeIdentifier) {
      final languageCode = _extractLanguageCode(localeIdentifier);
      final name = languageCodeToName[languageCode] ?? localeIdentifier; // Fallback to locale identifier if not found
      return PopupMenuItem<String>(
        enabled: true,
        value: localeIdentifier,
        child: Text(
          name,
          style: GoogleFonts.questrial(
            color: _currentLocaleId == localeIdentifier
                ? ColorTheme.secondary // Background color for selected item
                : ColorTheme.accent,
          ),
        ),
      );
    }).toList();
  }



  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    final _agentDetails = chatProvider.agentDetails;
    final _isDeployed = chatProvider.isDeployed ?? false; // Default to false if null
    Size screenSize = MediaQuery.of(context).size;
    double containerHeight = screenSize.height * 0.1;
    if (_agentDetails == null) {
      // Handle the case where _agentDetails is null
      return Scaffold(
        body: Center(
          child: SpinKitCubeGrid(
            color: ColorTheme.primary,
          ),
        ),
      );
    }
    _agentName = _agentDetails.displayName;
    return Scaffold(
      //  backgroundColor: ColorTheme.primary.withOpacity(0.05),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _agentDetails.displayName!,
                style: GoogleFonts.questrial(
                  color: ColorTheme.secondary,
                  fontSize: 20,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isOnline ? "online" : "offline",
                style: GoogleFonts.montserrat(
                  color: ColorTheme.secondary,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),


        centerTitle: false,
        titleTextStyle: GoogleFonts.questrial(
            color: ColorTheme.secondary,
            fontSize: 20
        ),
        backgroundColor: ColorTheme.primary,
        leading: Container(
          margin: EdgeInsets.all(10),

          child:Stack(

            children: [

              Container(
                width: 50, // Ensure container width matches image size
                height: 50, // Ensure container height matches image size
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorTheme.secondary, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: ColorTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          titlePadding: EdgeInsets.all(16.0),
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            'Description',
                            style: GoogleFonts.questrial(
                              color: ColorTheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Text(
                              _agentDetails.description ??
                                  'Ask any questions you have about the products store, I\'ll provide all the information you need?',
                              style: GoogleFonts.questrial(
                                color: ColorTheme.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: ColorTheme.primary, backgroundColor: ColorTheme.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Got It',
                                style: GoogleFonts.questrial(
                                  color: ColorTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ClipOval(
                    child: _agentDetails == null || _agentDetails.image == null
                        ? Image.asset(
                      "assets/haiva.png",
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      _agentDetails.image!,
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/haiva.png",
                          height: 30,
                          width: 30,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),

              if (_isOnline)
                Positioned(
                  bottom: 1,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.red, // Green for online, Red for offline
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                ),

              Positioned(
                bottom: 1,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isOnline ?null: Colors.red, // Green for online, Red for offline
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                ),
              ),

            ],
          ),


        ),

        actions: [
          IconButton(
            icon: Icon(
              isSpeaking ? Icons.volume_up_rounded : Icons.volume_off,
              color: ColorTheme.secondary,
            ),
            onPressed: () {
              setState(() {
                if (isSpeaking) {
                  stopSpeaking; // Call method to stop speaking
                } else {
                  // Start speaking
                }
                isSpeaking = !isSpeaking; // Toggle the speaking state
              });
            },
          ),
          PopupMenuButton<String>(
            popUpAnimationStyle: AnimationStyle.noAnimation,
            tooltip: 'Show languages',
            initialValue: _currentLocaleId,
            shadowColor: ColorTheme.primary.withOpacity(1),
            color: ColorTheme.primary,
            icon: Icon(Icons.translate, color: ColorTheme.secondary),
            onSelected: (String value) {

              setState(() {
                _currentLocaleId = value;
              });
              //     print("Selected locale: $_currentLocaleId");
              //      _speechToText.stop();
              //      _speechToText.listen(localeId: _currentLocaleId);
            },
            itemBuilder: (BuildContext context) {
              // Assuming _agentDetails.languages is a list of locale identifiers
              final List<String> localeIdentifiers = _agentDetails.languages!;
              return _buildLanguageMenuItems(localeIdentifiers);
            },
          )


          ,IconButton(
            onPressed: () {
              _showRefreshAlertDialog();
              //  _changeTheme();
            },
            icon: Icon(
              CupertinoIcons.refresh,
              color: ColorTheme.secondary,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        AgentSelectionPage()

                ),
              );
              //  _changeTheme();
            },
            icon: Icon(
              CupertinoIcons.settings,
              color: ColorTheme.secondary,
            ),
          ),


        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 16, 1, 16),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      if (welcomemessagedata.type =="screen" && index == 0 && _messages[index].type == MessageType.bot) {
                        return SizedBox.shrink();
                      }
                      final message = _messages[index];
                      return Column(
                        children: [
                          ChatBubbleHaiva(
                            message: message,
                            onSendMessage: (text, isClicked,) => sendMessage(text, action: isClicked),

                            onFormSubmit: (formData) {// Debugging line
                              sendMessage('the form data is', displayMessage: false, action: _isclicked, payload: formData);
                            },
                            agentDetails: _agentDetails,
                            locale: _currentLocaleId, stopSpeaking: !isSpeaking,
                          )



                          ,SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),


                Visibility(
                  visible: _isWelcomeVisible && welcomemessagedata.type == "screen",
                  child: Column(
                    children: [
                      ClipOval(
                        child: _agentDetails == null || _agentDetails.image == null
                            ? Image.asset("assets/haiva.png", height: 50, width: 50)
                            : Image.network(
                          _agentDetails.image!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset("assets/haiva.png", height: 50, width: 50);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _agentDetails.description ?? "Ask any questions you have, and I'll provide all the information you need!",
                          style: GoogleFonts.questrial(
                            color: ColorTheme.accent.withOpacity(1),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Number of columns
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio: 1, // Adjust to fit your needs
                          ),
                          itemCount: welcomemessagedata.data['sampleQuestions']?.length ?? 0,
                          itemBuilder: (context, index) {
                            // Ensure sampleQuestions is correctly accessed
                            List<String> sampleQuestions = List<String>.from(welcomemessagedata.data['sampleQuestions'] ?? []);

                            return GestureDetector(
                              onTap: () {
                                sendMessage(sampleQuestions[index]);
                                setState(() {
                                  _isWelcomeVisible = false; // Hide the welcome message when a question is clicked

                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorTheme.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: ColorTheme.primary,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    sampleQuestions[index],
                                    style: GoogleFonts.questrial(
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),



                Container(

                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: ColorTheme.primary,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                // child: IconButton(
                                //   icon: Icon(Icons.attach_file),
                                //   color: ColorTheme.accent,
                                //   iconSize: 16,
                                //   onPressed: _uploadFile,
                                // ),
                              ),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 100, // Adjust this value as needed
                                  ),
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: TextField(
                                        enabled: _isDeployed,
                                        textInputAction: TextInputAction.send,
                                        cursorColor: ColorTheme.accent,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        controller: _controller,
                                        decoration: InputDecoration(
                                          hintText: _isDeployed
                                              ? 'Enter a message ...'
                                              : 'Agent is not deployed. Please deploy to enter message ...',
                                          border: InputBorder.none, // Ensures no underline is shown
                                          enabledBorder: InputBorder.none, // Removes underline when not focused
                                          focusedBorder: InputBorder.none, // Removes underline when focused
                                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                                        ),
                                        style: GoogleFonts.questrial(
                                          color: ColorTheme.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        onSubmitted: (text) => _isloading ? null : sendMessage(text),
                                      )
                                      ,
                                    ),
                                  ),
                                ),
                              ),
                              if (_speechEnabled && _agentDetails.isSpeech2Text == true)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0,6,6,6),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ColorTheme.primary,
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _speechListening ? CupertinoIcons.mic_fill : CupertinoIcons.mic_slash,
                                        color: ColorTheme.secondary,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        if (_speechListening) {
                                          //    _controller.clear();
                                          _stopListening();
                                        } else {
                                          //  _controller.clear();
                                          _startListening();

                                        }
                                      },
                                    ),

                                  )
                                  ,
                                ),


                              Padding(
                                padding: const EdgeInsets.fromLTRB(0,6,6,6),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorTheme.primary,
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: IconButton(
                                    color: ColorTheme.secondary,
                                    icon: Icon(_isloading ? Icons.stop_circle : Icons.send_rounded),
                                    iconSize: 16,
                                    onPressed: () {
                                      // if(_prevMessage != null ){
                                      //   sendMessage(_controller.text);
                                      //   sendMessage(_controller.text);
                                      // }
                                      _isloading ? null : sendMessage(_controller.text);
                                      setState(() {
                                        _controller.clear();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                )

              ],
            ),
          ),
          if (_messages.isNotEmpty && _messages.last.text != null && _messages.last.text!.contains('Order') && _messages.last.text!.contains('successful'))
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              shouldLoop: false,
              createParticlePath: (size) {
                return createStarPath(8.0, 4.0, 10); // Adjust radius and number of points as needed
              },
              colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),

        ],
      ),
    );
  }
}
Path createStarPath(double outerRadius, double innerRadius, int points) {
  final path = Path();
  final angle = (pi * 2) / points;

  for (int i = 0; i < points; i++) {
    final isOuterPoint = i % 2 == 0;
    final radius = isOuterPoint ? outerRadius : innerRadius;
    final x = radius * cos(i * angle);
    final y = radius * sin(i * angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}