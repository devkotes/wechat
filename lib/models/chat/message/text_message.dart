import '../chat_message.dart';
import '../../../helper/enum.dart';

class TextMessage extends ChatMessage {
  final String content;

  TextMessage({
    required super.uid,
    required super.messageType,
    required super.senderId,
    required super.createdAt,
    required super.groupAt,
    required super.readAt,
    required super.updateAt,
    required this.content,
  });

  factory TextMessage.fromJson(Map<String, dynamic> json) => TextMessage(
        uid: json["uid"],
        messageType: MessageType.text,
        senderId: json["senderId"],
        createdAt: json["createdAt"],
        groupAt: json["groupAt"],
        readAt: json["readAt"],
        updateAt: json["updateAt"],
        content: json["content"],
      );

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "messageType": messageType.name,
        "senderId": senderId,
        "createdAt": createdAt,
        "groupAt": groupAt,
        "readAt": readAt,
        "updateAt": updateAt,
        "content": content,
      };
}
