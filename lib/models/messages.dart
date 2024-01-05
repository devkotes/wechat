class Message {
  Message({
    required this.toId,
    required this.type,
    required this.msg,
    required this.read,
    required this.fromId,
    required this.sent,
  });
  late String toId;
  late MessageType type;
  late String msg;
  late String read;
  late String fromId;
  late String sent;

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    type = json['type'].toString() == MessageType.image.name
        ? MessageType.image
        : MessageType.text;
    msg = json['msg'].toString();
    read = json['read'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['type'] = type.name;
    data['msg'] = msg;
    data['read'] = read;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum MessageType {
  text,
  image,
}
