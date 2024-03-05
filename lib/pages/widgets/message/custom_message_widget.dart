import 'package:flutter/material.dart';
import 'package:wechat/helper/text_utils.dart';
import 'package:wechat/models/chat/chat.dart';
import 'package:wechat/models/chat_user.dart';

import '../../../helper/my_date_utils.dart';
import '../../../main.dart';
import '../../../service/firebase_service.dart';

class CustomMessageWidget extends StatelessWidget {
  final CustomMessage message;
  final ChatUser user;
  final bool isMe;
  const CustomMessageWidget({
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
  final CustomMessage message;
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
              color: Colors.transparent,
              border: Border.all(color: const Color(0xff9D21E6)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        message.metadata.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff9D21E6),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        message.metadata.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff302B2B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint('ID METADATA : ${message.metadata.id}');
                      },
                      child: Center(
                        child: Container(
                          width: 145,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xff9D21E6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff9D21E6).withOpacity(0.25),
                                blurRadius: 15.0,
                                spreadRadius: 0.0,
                                offset: const Offset(
                                  0.0,
                                  7.0,
                                ), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Buka ${TextUtils.capitalize(message.metadata.type.name)}',
                              style: const TextStyle(
                                color: Color(0xffF4EBFE),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
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
                          ? const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.done_all_rounded,
                                  color: Color(0xffBB88FC),
                                  size: 15,
                                ),
                              ),
                            )
                          : const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5),
                                child: Icon(
                                  Icons.done_rounded,
                                  color: Color(0xffBB88FC),
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
  final CustomMessage message;
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
            padding: EdgeInsets.all(mq.width * .04),
            margin: EdgeInsets.symmetric(
              horizontal: mq.width * .04,
              vertical: mq.height * .01,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: const Color(0xff9D21E6)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        message.metadata.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff9D21E6),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        message.metadata.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff302B2B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        debugPrint('ID METADATA : ${message.metadata.id}');
                      },
                      child: Center(
                        child: Container(
                          width: 145,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xff9D21E6),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xff9D21E6).withOpacity(0.25),
                                blurRadius: 15.0,
                                spreadRadius: 0.0,
                                offset: const Offset(
                                  0.0,
                                  7.0,
                                ), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Buka ${TextUtils.capitalize(message.metadata.type.name)}',
                              style: const TextStyle(
                                color: Color(0xffF4EBFE),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
