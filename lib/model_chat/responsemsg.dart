import 'package:flutter/cupertino.dart';

enum MessageType {
  user,
  bot,
}

class ResponseMessage {
  final String? responseType;
  final MessageType type;
  final DateTime timestamp;
  final String? text;
  final int? statusCode;
  final String? threadId;
  final String? sessionId;
  final List<String>? responseTypesAgent;
  final Widget? customWidget;
  final List<dynamic>? payload;
  final Map<String, dynamic>? wholeResponsePayload;
  final Map<String, dynamic>? haivaMessage;

  ResponseMessage(
      this.type,
      this.timestamp,  {
        this.responseType,
        this.payload,
        this.text,
        this.haivaMessage,
        this.wholeResponsePayload,
        this.sessionId,
        this.customWidget,
        this.threadId,
        this.responseTypesAgent, Map<String, dynamic>? customComponent,  this.statusCode,
      });

  factory ResponseMessage.fromJson(Map<String, dynamic> json, {bool isMarkdown = false}) {
    return ResponseMessage(
      _parseMessageType(json['responseType']),
      DateTime.now(), // Provide the current timestamp
      responseType: json['responseType'],
      text: (json['text'] != null && json['text']['text'] != null)
          ? json['text']['text'][0]
          : null,
      wholeResponsePayload: json['wholeResponsePayload'],

    );
  }

  static MessageType _parseMessageType(String? responseType) {
    switch (responseType) {
      case 'user':
        return MessageType.user;
      case 'bot':
        return MessageType.bot;
      default:
        return MessageType.bot; // Default to bot if responseType is not recognized
    }
  }
}
