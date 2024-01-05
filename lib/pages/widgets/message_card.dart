import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/my_date_utils.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/messages.dart';
import 'package:wechat/service/firebase_service.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  const MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return (FirebaseService.user.uid != message.fromId)
        ? _purpleMessage(context)
        : _greenMessage(context);
  }

  Widget _purpleMessage(BuildContext ctx) {
    if (message.read.isEmpty) {
      FirebaseService.updateMessageReadStatus(message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              (message.type == MessageType.image)
                  ? mq.width * .03
                  : mq.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade300.withOpacity(0.7),
              border: Border.all(color: Colors.deepPurple.shade400),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: (message.type == MessageType.text)
                ? Text(
                    message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: message.msg,
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
            MyDateUtils.getFormattedTime(context: ctx, time: message.sent),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        )
      ],
    );
  }

  Widget _greenMessage(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * .04),
            if (message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.deepPurpleAccent,
                size: 20,
              ),
            const SizedBox(width: 2),
            Text(
              MyDateUtils.getFormattedTime(context: ctx, time: message.sent),
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
              (message.type == MessageType.image)
                  ? mq.width * .03
                  : mq.width * .04,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: (message.type == MessageType.text)
                ? Text(
                    message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: message.msg,
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
