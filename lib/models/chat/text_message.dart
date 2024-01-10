import 'package:wechat/models/chat/chat_message.dart';
import 'package:wechat/models/messages.dart';

class TextMessage extends ChatMessage {
  final String content;
  final MessageType type;

  TextMessage({
    required super.uid,
    required super.senderId,
    required super.groupAt,
    required super.sentAt,
    required this.content,
    required this.type,
  });

  factory TextMessage.fromJson(Map<String, dynamic> json) => TextMessage(
        uid: json["uid"],
        senderId: json["senderId"],
        groupAt: json["groupAt"],
        sentAt: json["sentAt"],
        content: json["content"],
        type: MessageType.text,
      );

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "senderId": senderId,
        "groupAt": groupAt,
        "sentAt": sentAt,
        "content": content,
        "type": type.name
      };
}
