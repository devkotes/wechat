// To parse this JSON data, do
//
//     final chatMessage = chatMessageFromJson(jsonString);

import 'dart:convert';

import '../../helper/enum.dart';

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(ChatMessage data) => json.encode(data.toJson());

class ChatMessage {
  String uid;
  MessageType messageType;
  String senderId;
  String createdAt;
  String groupAt;
  String readAt;
  String updateAt;

  ChatMessage({
    required this.uid,
    required this.messageType,
    required this.senderId,
    required this.createdAt,
    required this.groupAt,
    required this.readAt,
    required this.updateAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        uid: json["uid"],
        messageType: (json['messageType'].toString() == MessageType.image.name)
            ? MessageType.image
            : (json['messageType'].toString() == MessageType.system.name)
                ? MessageType.system
                : (json['messageType'].toString() == MessageType.custom.name)
                    ? MessageType.custom
                    : MessageType.text,
        senderId: json["senderId"],
        createdAt: json["createdAt"],
        groupAt: json["groupAt"],
        readAt: json["readAt"],
        updateAt: json["updateAt"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "messageType": messageType.name,
        "senderId": senderId,
        "createdAt": createdAt,
        "groupAt": groupAt,
        "readAt": readAt,
        "updateAt": updateAt,
      };
}
