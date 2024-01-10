import 'package:wechat/models/chat/chat_message.dart';
import 'package:wechat/models/messages.dart';

class ImageMessage extends ChatMessage {
  final String content;
  final MessageType type;
  final String caption;

  ImageMessage({
    required super.uid,
    required super.senderId,
    required super.groupAt,
    required super.sentAt,
    required this.content,
    required this.type,
    required this.caption,
  });

  factory ImageMessage.fromJson(Map<String, dynamic> json) => ImageMessage(
        uid: json["uid"],
        senderId: json["senderId"],
        groupAt: json["groupAt"],
        sentAt: json["sentAt"],
        content: json["content"],
        type: MessageType.image,
        caption: json["caption"],
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "senderId": senderId,
      "groupAt": groupAt,
      "sentAt": sentAt,
      "content": content,
      "type": type.name,
      "caption": caption
    };
  }
}
