class Message {
  Message({
    required this.uid,
    required this.senderId,
    required this.messageType,
    required this.content,
    required this.readAt,
    required this.createdAt,
    required this.groupAt,
    // Optional
    this.updateAt,
    // for messageType File & Image
    this.caption,
    // for messageType File
    this.fileName,
    this.mimeType,
    this.size,
  });
  late String uid;
  late String senderId;
  late MessageType messageType;
  late String content;
  late String readAt;
  late String createdAt;
  late String groupAt;

  // Optional
  String? updateAt;
  // for messageType File & Image
  String? caption;
  // for messageType File
  String? fileName;
  String? mimeType;
  String? size;

  // for Message Custom & System
  CustomMetadata? customMetadata;

  Message.fromJson(Map<String, dynamic> json) {
    uid = json['uid'].toString();
    senderId = json['senderId'].toString();
    messageType = (json['messageType'].toString() == MessageType.image.name)
        ? MessageType.image
        : (json['messageType'].toString() == MessageType.file.name)
            ? MessageType.file
            : (json['messageType'].toString() == MessageType.custom.name)
                ? MessageType.custom
                : (json['messageType'].toString() == MessageType.system.name)
                    ? MessageType.system
                    : MessageType.text;
    content = json['content'].toString();
    readAt = json['readAt'].toString();
    createdAt = json['createdAt'].toString();
    groupAt = json['groupAt'].toString();
    // Optional
    updateAt = json['updateAt'].toString();
    // for messageType File & Image
    caption = json['caption'].toString();
    // for messageType File
    fileName = json['fileName'].toString();
    mimeType = json['mimeType'].toString();
    size = json['size'].toString();

    // for Message Custom & System
    customMetadata = json["metadata"] == null
        ? null
        : CustomMetadata.fromJson(json["metadata"]);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['senderId'] = senderId;
    data['messageType'] = messageType.name;
    data['content'] = content;
    data['readAt'] = readAt;
    data['createdAt'] = createdAt;
    data['groupAt'] = groupAt;

    // Optional
    data['updateAt'] = updateAt ?? '';
    // for messageType File & Image
    data['caption'] = caption;
    data['fileName'] = fileName;
    data['mimeType'] = mimeType;
    data['size'] = size;

    // for Message Custom & System
    data['metadata'] = customMetadata?.toJson();

    return data;
  }
}

class CustomMetadata {
  CustomMetadata({
    required this.id,
    required this.title,
    required this.type,
    this.description,
  });

  late String id;
  late String title;
  late CustomMessageType type;
  String? description;

  CustomMetadata.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    type = (json['type'].toString() == CustomMessageType.material.name)
        ? CustomMessageType.material
        : (json['type'].toString() == CustomMessageType.assignment.name)
            ? CustomMessageType.assignment
            : (json['type'].toString() == CustomMessageType.quiz.name)
                ? CustomMessageType.quiz
                : (json['type'].toString() == CustomMessageType.uts.name)
                    ? CustomMessageType.uts
                    : CustomMessageType.uas;
    title = json['title'].toString();
    description = json['description'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type.name;
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

enum MessageType {
  text,
  image,
  file,
  custom,
  system,
}

enum CustomMessageType {
  material,
  assignment,
  quiz,
  uts,
  uas;
}
