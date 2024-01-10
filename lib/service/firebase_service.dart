import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/messages.dart';
import 'package:mime/mime.dart';

class FirebaseService {
  // untuk authentication firebase
  static FirebaseAuth auth = FirebaseAuth.instance;

  // untuk akses cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // untuk akses firebase store
  static FirebaseStorage storage = FirebaseStorage.instance;

  // untuk akses firebase messaging [PUSH NOTIFICATION]
  // https://fcm.googleapis.com/fcm/send

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // variable user login
  static late ChatUser me;

  // current user
  static User get user => auth.currentUser!;

  // key Messaging API
  static String get messageKey =>
      'AAAA5PUBDs0:APA91bHhPwESUkz9JvTgJfuxZdApkytfZ1E5mpOxjYtIsUNAmrgBqVy5_1M6vr7eCsF02_EZq6zkC4GtvHUnaXQL3PYhDMpJVLShyDpnHzqsD6WqdM4jiGzsQHkFfz2LE4iUdhzpvKEF';

  // token firebase messaging
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((token) {
      // if (token != null) {
      //   me.pushToken = token;
      //   debugPrint('ME PUSH TOKEN : $token');
      // }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message Data ${message.data}');
      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification ${message.notification}');
      }
    });
  }

  // Send notification
  static Future<void> sendNotification(
      ChatUser chatUser, String content) async {
    try {
      final body = {
        // "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": content,
          "android_channel_id": "your_channel_id",
          "sound": "default",
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "some_data": "User ID : ${me.id}"
        },
      };

      var res = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'key=$messageKey',
        },
        body: json.encode(body),
      );

      debugPrint('Status Code ${res.statusCode}');
      debugPrint('Body ${res.body}');
    } catch (e) {
      debugPrint('Send Notification $e');
    }
  }

  // cek apakah user tersedia atau belum
  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // Setting user status to active
        updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // membuat user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      isOnline: false,
      id: user.uid,
      createdAt: time,
      email: user.email.toString(),
      photoUrl: user.photoURL.toString(),
      lastActive: time,
      name: user.displayName.toString(),
    );

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // Get Data All User
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // Mengedit User Info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      "name": me.name,
    });
  }

  // Upload Foto Profile
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    debugPrint('Extension : $ext');
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      debugPrint('Data Transferred ${p0.bytesTransferred / 100} kb');
    });

    me.photoUrl = await ref.getDownloadURL();

    await firestore.collection('users').doc(user.uid).update({
      "photoUrl": me.photoUrl,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await firestore.collection('users').doc(user.uid).update({
      "is_online": isOnline,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  // ==================== CHAT  ============================= //

  // Generate ROOM ID
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(
      ChatUser user) {
    return firestore
        .collection('rooms/${getConversationId(user.id)}/messages/')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mengirim Pesan
  static Future<void> sendMessage(
      ChatUser chatUser, String content, MessageType type) async {
    try {
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      final Message message = Message(
        uid: 'xxxx-xxxyyy-xxxxttt',
        messageType: type,
        content: content,
        readAt: '',
        senderId: user.uid,
        createdAt: time,
        groupAt: time,
      );

      final ref = firestore
          .collection('rooms/${getConversationId(chatUser.id)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) {
        debugPrint('SEND notification');
        // sendNotification(chatUser, type == MessageType.text ? content : 'image');
      });
    } catch (e) {
      debugPrint('Send Message $e');
    }
  }

  // UPDATE Read Status
  static Future<void> updateMessageReadStatus(
      ChatUser chatUser, Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('rooms/${getConversationId(chatUser.id)}/messages/')
        .doc(message.createdAt)
        .update({'readAt': time});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('rooms/${getConversationId(user.id)}/messages/')
        .limit(1)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      debugPrint('Data Transferred ${p0.bytesTransferred / 100} kb');
    });

    // GET IMAGE URL FROM STORAGE
    final imageUrl = await ref.getDownloadURL();

    // Kirim pesan gambar
    await sendMessage(chatUser, imageUrl, MessageType.image);
  }

  // Delete Message
  static Future<void> deleteMessage(ChatUser chatUser, Message message) async {
    await firestore
        .collection('rooms/${getConversationId(chatUser.id)}/messages/')
        .doc(message.createdAt)
        .delete();

    if (message.messageType == MessageType.image) {
      await storage.refFromURL(message.content).delete();
    }
  }

  //update message
  static Future<void> updateMessage(
      ChatUser chatUser, Message message, String updatedcontent) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    await firestore
        .collection('rooms/${getConversationId(chatUser.id)}/messages/')
        .doc(message.createdAt)
        .update({'content': updatedcontent, 'updateAt': time});
  }

  static Future<void> sendChatFile(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final mimeType = lookupMimeType(file.path);
    debugPrint('EXT : $ext');
    debugPrint('mimeType : $mimeType');
    // final ref = storage.ref().child(
    //     'files/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    // await ref.putFile(file, SettableMetadata(contentType: mimeType)).then((p0) {
    //   debugPrint('Data Transferred ${p0.bytesTransferred / 100} kb');
    // });

    // // GET IMAGE URL FROM STORAGE
    // final getUrl = await ref.getDownloadURL();

    // // Kirim pesan gambar
    // await sendMessage(chatUser, getUrl, MessageType.image);
  }
}
