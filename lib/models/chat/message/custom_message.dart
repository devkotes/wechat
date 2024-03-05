import '../../../helper/enum.dart';
import '../chat_message.dart';

class CustomMessage extends ChatMessage {
  final String content;
  final MetaMessage metadata;

  CustomMessage({
    required super.uid,
    required super.messageType,
    required super.senderId,
    required super.createdAt,
    required super.groupAt,
    required super.readAt,
    required super.updateAt,
    required this.content,
    required this.metadata,
  });

  factory CustomMessage.fromJson(Map<String, dynamic> json) => CustomMessage(
        uid: json["uid"],
        messageType: MessageType.custom,
        senderId: json["senderId"],
        createdAt: json["createdAt"],
        groupAt: json["groupAt"],
        readAt: json["readAt"],
        updateAt: json["updateAt"],
        content: json["content"],
        metadata: MetaMessage.fromJson(json["metadata"]),
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
      "metadata": metadata.toJson(),
    };
  }
}

class MetaMessage {
  String id;
  CustomMessageType type;
  String title;
  String description;

  MetaMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
  });

  factory MetaMessage.fromJson(Map<String, dynamic> json) => MetaMessage(
        id: json["id"],
        type: (json['type'].toString() == CustomMessageType.material.name)
            ? CustomMessageType.material
            : (json['type'].toString() == CustomMessageType.assignment.name)
                ? CustomMessageType.assignment
                : (json['type'].toString() == CustomMessageType.quiz.name)
                    ? CustomMessageType.quiz
                    : (json['type'].toString() == CustomMessageType.uts.name)
                        ? CustomMessageType.uts
                        : CustomMessageType.uas,
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type.name,
        "title": title,
        "description": description,
      };
}
