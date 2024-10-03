import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../model_chat/agent_detail.dart';
import '../../model_chat/responsemsg.dart';
import '../../theme/colortheme.dart';
import 'customcomponenthaiva.dart';


class ChatBubbleHaiva extends StatefulWidget {
  final ResponseMessage message;
  final bool stopSpeaking;
  final Function(String, bool) onSendMessage;
  final AgentConfigs agentDetails;
  final Function(Map<String, dynamic>) onFormSubmit;
  final String? locale;
  ChatBubbleHaiva(
      {Key? key, required this.message,
        required this.onSendMessage,
        required this.onFormSubmit,
        required this.agentDetails,
        this.locale, required this.stopSpeaking})
      : super(key: key);

  @override
  State<ChatBubbleHaiva> createState() => _ChatBubbleFlowState();

}

class _ChatBubbleFlowState extends State<ChatBubbleHaiva> with SingleTickerProviderStateMixin{
   late String locale;
  bool isHovered = false;
   bool _speakerOff = false;
bool noComponent = false;
   late AnimationController _controller;
   late Animation<double> _scaleAnimation;

   @override
   void initState() {
     super.initState();
    // print("Locale form chatbubble: ${widget.locale}");
     locale = widget.locale ?? 'en-US';
     _controller = AnimationController(

       duration: Duration(milliseconds: 300), vsync: this, // Animation duration
     );

     _scaleAnimation = CurvedAnimation(
       parent: _controller,
       curve: Curves.easeInExpo, // You can try different curves for the "pop-in" effect
     );

     _controller.forward();
   }
   @override
   void dispose() {
     _controller.dispose();
     super.dispose();
   }
  @override
  Widget build(BuildContext context) {
    final isUserMessage = widget.message.type == MessageType.user;
    return isUserMessage ? _buildUserMessage(widget.agentDetails) : _buildBotMessage(
        widget.agentDetails);

  }

  Widget _buildUserMessage(AgentConfigs agentDetails) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: ColorTheme.primary, // Example usage with condition
                  
                      border: Border.all(
                        color: ColorTheme.primary,
                        // Set the border color
                        width: 1.0, // Set the border width
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                  
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                  
                        SelectableText(
                          widget.message.text ?? '',
                          style: GoogleFonts.questrial(
                            color: ColorTheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 5,),
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a').format(widget.message.timestamp),
                style: GoogleFonts.questrial(
                  color: ColorTheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }


   Widget _buildBotMessage(AgentConfigs agentDetails) {
     return Column(
       children: [
         Row(
           mainAxisAlignment: MainAxisAlignment.start,
           children: [
             SizedBox(width: 10),
             Flexible(
               child: Container(
                 child: Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       if (widget.message.customWidget != null)
                         widget.message.customWidget!,
                       if (widget.message.payload != null)
                         CustomComponentHaiva(
                           stopSpeaking: widget.stopSpeaking,
                           payload: widget.message.payload!,
                           onButtonPressed: (String message, bool isClicked) {
                             widget.onSendMessage(message, isClicked);
                           },
                           onFormSubmit: (formData) {
                             //   print('Form data received in onFormSubmit: $formData'); // Debugging line
                             widget.onFormSubmit(formData);
                           },
                           locale: locale,
                           speakerOff: _speakerOff,
                         )

                     ],
                   ),
                 ),
               ),
             ),
           ],
         ),
         if (widget.message.payload != null) Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
               child: Row(
                 children: [
                   Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(
                         color: ColorTheme.primary,
                         width: 1,
                       ),
                     ),
                     child: ClipOval(
                       child: agentDetails == null || agentDetails.image == null
                           ? Image.asset(
                         "assets/haiva.png",
                         height: 20,
                         width: 20,
                         fit: BoxFit.cover,
                       )
                           : Image.network(
                         agentDetails.image!,
                         height: 20,
                         width: 20,
                         fit: BoxFit.cover,
                         errorBuilder: (context, error, stackTrace) {
                           return Image.asset(
                             "assets/haiva.png",
                             height: 20,
                             width: 20,
                             fit: BoxFit.cover,
                           );
                         },
                       ),
                     ),
                   ),
                   SizedBox(width: 5),
                   Text(
                     agentDetails.displayName ?? '',
                     style: GoogleFonts.questrial(
                       color: ColorTheme.primary,
                       fontSize: 10,
                     ),
                   ),
                   SizedBox(width: 5),
                   Text(
                     DateFormat('hh:mm a').format(widget.message.timestamp),
                     style: GoogleFonts.questrial(
                       color: ColorTheme.accent,
                       fontSize: 10,
                     ),
                   ),
                 ],
               ),
             ),
           ],
         ),
       ],
     );
   }

}
