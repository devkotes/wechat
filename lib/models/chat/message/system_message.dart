import '../../../helper/enum.dart';
import '../chat_message.dart';

class SystemMessage extends ChatMessage {
  final String content;
  final MetadataMessage metadata;

  SystemMessage({
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

  factory SystemMessage.fromJson(Map<String, dynamic> json) => SystemMessage(
        uid: json["uid"],
        messageType: MessageType.system,
        senderId: json["senderId"],
        createdAt: json["createdAt"],
        groupAt: json["groupAt"],
        readAt: json["readAt"],
        updateAt: json["updateAt"],
        content: json["content"],
        metadata: MetadataMessage.fromJson(json["metadata"]),
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

class MetadataMessage {
  String? id;
  SystemMessageType type;
  String title;
  bool? isAttendance;

  MetadataMessage({
    this.id,
    required this.type,
    required this.title,
    this.isAttendance,
  });

  factory MetadataMessage.fromJson(Map<String, dynamic> json) =>
      MetadataMessage(
        id: json["id"],
        type: (json['type'].toString() == SystemMessageType.addMember.name)
            ? SystemMessageType.addMember
            : (json['type'].toString() == SystemMessageType.removeMember.name)
                ? SystemMessageType.removeMember
                : (json['type'].toString() ==
                        SystemMessageType.createGroup.name)
                    ? SystemMessageType.createGroup
                    : (json['type'].toString() ==
                            SystemMessageType.leaveGroup.name)
                        ? SystemMessageType.leaveGroup
                        : (json['type'].toString() ==
                                SystemMessageType.deleteGroup.name)
                            ? SystemMessageType.deleteGroup
                            : (json['type'].toString() ==
                                    SystemMessageType.addZoom.name)
                                ? SystemMessageType.addZoom
                                : (json['type'].toString() ==
                                        SystemMessageType.removeZoom.name)
                                    ? SystemMessageType.removeZoom
                                    : SystemMessageType.session,
        title: json["title"],
        isAttendance: json["isAttendance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? '',
        "type": type.name,
        "title": title,
        "isAttendance": isAttendance,
      };
}
