import '../../../helper/enum.dart';
import '../chat_message.dart';

class ImageMessage extends ChatMessage {
  final String content;
  final String? caption;

  ImageMessage({
    required super.uid,
    required super.messageType,
    required super.senderId,
    required super.createdAt,
    required super.groupAt,
    required super.readAt,
    required super.updateAt,
    required this.content,
    this.caption,
  });

  factory ImageMessage.fromJson(Map<String, dynamic> json) => ImageMessage(
        uid: json["uid"],
        messageType: MessageType.image,
        senderId: json["senderId"],
        createdAt: json["createdAt"],
        groupAt: json["groupAt"],
        readAt: json["readAt"],
        updateAt: json["updateAt"],
        content: json["content"],
        caption: json["caption"],
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "messageType": messageType.name,
      "senderId": senderId,
      "createdAt": createdAt,
      "groupAt": groupAt,
      "readAt": readAt,
      "updateAt": updateAt,
      "content": content,
      "caption": caption ?? '',
    };
  }
}
