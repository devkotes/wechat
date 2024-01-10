import 'package:flutter/material.dart';
import 'package:wechat/models/chat_user.dart';

import '../../../helper/my_date_utils.dart';
import '../../../main.dart';
import '../../../models/messages.dart';
import '../../../service/firebase_service.dart';

class FileMessage extends StatelessWidget {
  final Message message;
  final ChatUser user;
  final bool isMe;
  const FileMessage({
    super.key,
    required this.message,
    required this.isMe,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return (isMe)
        ? _PurpleMessage(message: message, isMe: isMe)
        : _GreyMessage(message: message, user: user, isMe: isMe);
  }
}

class _PurpleMessage extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _PurpleMessage({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (message.readAt.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blueAccent,
                size: 20,
              ),
            const SizedBox(width: 2),
            Text(
              MyDateUtils.getFormattedTime(
                  context: context, time: message.createdAt),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              (message.messageType == MessageType.image)
                  ? mq.width * .03
                  : mq.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 138, 6, 199),
              border: Border.all(color: Colors.deepPurpleAccent),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Text(
              'MESSAGE FILE : ${message.caption}',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreyMessage extends StatelessWidget {
  final Message message;
  final ChatUser user;
  final bool isMe;
  const _GreyMessage({
    required this.message,
    required this.user,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (message.readAt.isEmpty) {
      FirebaseService.updateMessageReadStatus(user, message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              (message.messageType == MessageType.image)
                  ? mq.width * .03
                  : mq.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300.withOpacity(0.7),
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              'MESSAGE FILE : ${message.caption}',
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtils.getFormattedTime(
                context: context, time: message.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        )
      ],
    );
  }
}
