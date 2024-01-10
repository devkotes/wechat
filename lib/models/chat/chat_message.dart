// To parse this JSON data, do
//
//     final chatMessage = chatMessageFromJson(jsonString);

import 'dart:convert';

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(ChatMessage data) => json.encode(data.toJson());

class ChatMessage {
  String uid;
  String senderId;
  String groupAt;
  String sentAt;
  String? readAt;

  ChatMessage({
    required this.uid,
    required this.senderId,
    required this.groupAt,
    required this.sentAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        uid: json["uid"],
        senderId: json["senderId"],
        groupAt: json["groupAt"],
        sentAt: json["sentAt"],
        readAt: json["readAt"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "senderId": senderId,
        "groupAt": groupAt,
        "sentAt": sentAt,
        "readAt": readAt,
      };
}
