import 'package:flutter/material.dart';
import 'package:wechat/models/chat/chat.dart';
import 'package:wechat/models/chat_user.dart';

import '../../../helper/my_date_utils.dart';
import '../../../main.dart';
import '../../../service/firebase_service.dart';

class TextMessageWidget extends StatelessWidget {
  final TextMessage message;
  final ChatUser user;
  final bool isMe;
  const TextMessageWidget({
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
  final TextMessage message;
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
            padding: EdgeInsets.all(mq.width * .04),
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
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xffFAFAFA),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      if (message.updateAt.isNotEmpty)
                        const TextSpan(
                          text: 'edited ',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xffBB88FC),
                          ),
                        ),
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
  final TextMessage message;
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
      debugPrint('UPDATE READ AT');
      FirebaseService.updateMessageReadStatus(user, message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: const BoxDecoration(
              color: Color(0xffEAE9E9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xff302B2B),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      if (message.updateAt.isNotEmpty)
                        const TextSpan(
                          text: 'edited ',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff9D9797),
                          ),
                        ),
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
