import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/models/chat/chat.dart';

import '../../../helper/my_date_utils.dart';
import '../../../main.dart';
import '../../../models/chat_user.dart';
import '../../../service/firebase_service.dart';

class ImageMessageWidget extends StatelessWidget {
  final ImageMessage message;
  final ChatUser user;
  final bool isMe;
  const ImageMessageWidget({
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
  final ImageMessage message;
  final bool isMe;
  const _PurpleMessage({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .03),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 138, 6, 199),
              border: Border.all(color: Colors.deepPurpleAccent),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .02),
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
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: MyDateUtils.getFormattedTime(
                            context: context, time: message.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xffBB88FC),
                        ),
                      ),
                      (message.readAt.isNotEmpty)
                          ? WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.done_all_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 15,
                                ),
                              ),
                            )
                          : WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.done_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 15,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GreyMessage extends StatelessWidget {
  final ImageMessage message;
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .03),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade300.withOpacity(0.7),
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .02),
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
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: MyDateUtils.getFormattedTime(
                            context: context, time: message.createdAt),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xff9D9797),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
