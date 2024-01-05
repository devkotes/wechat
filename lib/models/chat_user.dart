class ChatUser {
  ChatUser({
    required this.isOnline,
    required this.id,
    required this.createdAt,
    required this.pushToken,
    required this.email,
    required this.photoUrl,
    required this.about,
    required this.lastActive,
    required this.name,
  });
  late bool isOnline;
  late String id;
  late String createdAt;
  late String pushToken;
  late String email;
  late String photoUrl;
  late String about;
  late String lastActive;
  late String name;

  ChatUser.fromJson(Map<String, dynamic> json) {
    isOnline = json['is_online'];
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    photoUrl = json['photoUrl'] ?? '';
    about = json['about'] ?? '';
    lastActive = json['last_active'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_online'] = isOnline;
    data['id'] = id;
    data['created_at'] = createdAt;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['photoUrl'] = photoUrl;
    data['about'] = about;
    data['last_active'] = lastActive;
    data['name'] = name;
    return data;
  }
}
