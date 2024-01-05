import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/messages.dart';

class FirebaseService {
  // untuk authentication firebase
  static FirebaseAuth auth = FirebaseAuth.instance;

  // untuk akses cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // untuk akses firebase store
  static FirebaseStorage storage = FirebaseStorage.instance;

  // variable user login
  static late ChatUser me;

  // current user
  static User get user => auth.currentUser!;

  // cek apakah user tersedia atau belum
  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
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
      pushToken: '',
      email: user.email.toString(),
      photoUrl: user.photoURL.toString(),
      about: 'Hey, Iam Use Wechat',
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
      "about": me.about,
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
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // Mengirim Pesan
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, MessageType type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
      toId: chatUser.id,
      type: type,
      msg: msg,
      read: '',
      fromId: user.uid,
      sent: time,
    );

    final ref = firestore
        .collection('rooms/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  // UPDATE Read Status
  static Future<void> updateMessageReadStatus(Message message) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    firestore
        .collection('rooms/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'read': time});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('rooms/${getConversationId(user.id)}/messages/')
        .limit(1)
        .orderBy('sent', descending: true)
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
}
