import 'package:dart_discord/models/user.dart';
import 'dart:convert';
import 'dart:io';

class Message {
  String? sender;
  String? message;

  Message.channel(this.sender, this.message) {}

  String msgToJson() {
    String jsonString = jsonEncode(toMap());
    return jsonString;
  }

  Map<String, String> toMap() {
    return {
      'sender': sender!,
      'message': message!,
    };
  }

  static String newMessageinChannel(String userName) {
    stdout.write("Enter the message : ");
    String? message = stdin.readLineSync();
    Message newMessage = Message.channel(userName, message);
    String messageJson = newMessage.msgToJson();
    return messageJson;
  }
}
