import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../handler/customcomponent.dart';
import '../model_chat/agent_detail.dart';
import '../model_chat/responsemsg.dart';
import '../theme/colortheme.dart';


class ChatBubble extends StatefulWidget {
  final String agentId;
  final AgentConfigs? agent;
  final ResponseMessage message;
  final AgentConfigs agentDetails;
  final Function(String) onSendMessage;
  final bool isLoading;
  ChatBubble({Key? key, required this.message, required this.onSendMessage, required this.isLoading, required this.agentId, this.agent, required this.agentDetails}) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {


  @override
  void initState() {
    super.initState();
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: ColorTheme.primary, // Example usage with condition

                border: Border.all(
                  color: ColorTheme.primary.withOpacity(0.2),
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
                  SizedBox(height: 5),
                  Text(
                    DateFormat('hh:mm a').format(widget.message.timestamp),
                    style: GoogleFonts.questrial(
                      color: ColorTheme.secondary,
                      fontSize: 12,
                    //  fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          ),
          SizedBox(width: 10), // Space for better alignment
        ],
      ),
    );
  }

  Widget _buildBotMessage(AgentConfigs agentDetails) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          ClipOval(
            child: agentDetails.image == null
                ? Image.asset(agentDetails.image!, height: 30, width: 30)
                : FadeInImage.assetNetwork(
              placeholder: 'asssets/haiva-icon.png',
              image: 'asssets/haiva-icon.png',
              height: 10,
              width: 10,
              fit: BoxFit.cover,
            ),
          ),
       //   ClipOval(child: Image.network('https://s3.amazonaws.com/kommunicate-prod.s3/profile_pic/17096155577651709615556816-image440.png', height: 40, width: 40, fit: BoxFit.cover),
          SizedBox(width: 10), // Space for better alignment
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: ColorTheme.primary.withOpacity(0.1), // Example usage with condition
                border: Border.all(
                  color: ColorTheme.primary,// Set the border color
                  width: 1, // Set the border width
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.customWidget != null)
                    widget.message.customWidget!,
                  if (widget.message.wholeResponsePayload != null)

                    CustomComponent(
                      responseData: widget.message.wholeResponsePayload ?? {},
                      onButtonPressed: widget.onSendMessage, message: '',
                    ),
                  if (widget.message.text != null)
                    Text(
                      widget.message.text!,
                      style:GoogleFonts.questrial(
                        color: ColorTheme.secondary,
                        fontSize: 12,
                       // fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 5),
                  Text(
                    DateFormat('hh:mm a').format(widget.message.timestamp),
                    style: TextStyle(color: ColorTheme.secondary, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CopyButton extends StatefulWidget {
  final String textToCopy;
  final BuildContext outerContext;

  CopyButton({required this.textToCopy, required this.outerContext});

  @override
  _CopyButtonState createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _isCopied = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.textToCopy));
    setState(() {
      _isCopied = true;
    });
    ScaffoldMessenger.of(widget.outerContext).showSnackBar(
      SnackBar(
        content: Text(
          'Text copied to clipboard',
          style: GoogleFonts.questrial(
            color: ColorTheme.primary, // Text color
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ColorTheme.secondary, // Background color
      ),
    );
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copyToClipboard,
      icon: Icon(
        _isCopied ? Icons.check_circle_outline_rounded : Icons.copy_rounded,
        size: 10,
        color: ColorTheme.secondary,
      ),
      label: Text(
        'Copy',
        style: TextStyle(color: ColorTheme.secondary, fontSize: 10),
      ),
    );
  }
}