import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../helper/my_date_utils.dart';
import '../../../main.dart';
import '../../../models/chat_user.dart';
import '../../../models/messages.dart';
import '../../../service/firebase_service.dart';

class ImageMessage extends StatelessWidget {
  final Message message;
  final ChatUser user;
  final bool isMe;
  const ImageMessage({
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
            // const SizedBox(width: 5),
            // if (message.update.isNotEmpty)
            //   const Text(
            //     'Edited',
            //     style: TextStyle(
            //       fontSize: 10,
            //       color: Colors.black54,
            //     ),
            //   ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: message.content,
                placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(
                    Icons.image,
                    size: 20,
                  ),
                ),
              ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: message.content,
                placeholder: (context, url) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(
                    Icons.image,
                    size: 20,
                  ),
                ),
              ),
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
