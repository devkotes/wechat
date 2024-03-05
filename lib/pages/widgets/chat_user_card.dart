import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/my_date_utils.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat/chat.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/pages/chat_page.dart';
import 'package:wechat/service/firebase_service.dart';

import '../../helper/enum.dart';
import 'profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  ChatMessage? _msg;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: StreamBuilder(
        stream: FirebaseService.getLastMessage(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          List<ChatMessage> list = [];
          // final list =
          //     data?.map((e) => ChatMessage.fromJson(e.data())).toList() ?? [];
          // if (list.isNotEmpty) {
          //   _msg = list.first;
          // }

          data?.forEach((element) {
            if (element.data()['messageType'] == MessageType.image.name) {
              list.add(ImageMessage.fromJson(element.data()));
              // list.sort(
              //   (a, b) => b.createdAt.compareTo(a.createdAt),
              // );
            } else {
              list.add(TextMessage.fromJson(element.data()));
              // list.sort(
              //   (a, b) => b.createdAt.compareTo(a.createdAt),
              // );
            }
          });

          if (list.isNotEmpty) {
            _msg = list.first;
          }

          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(user: widget.user),
                  ));
            },
            leading: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user));
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .3),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: widget.user.photoUrl,
                      width: 60.0,
                      height: 60.0,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  if (widget.user.isOnline)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            title: Text(widget.user.name),
            subtitle: (_msg != null)
                ? (_msg!.messageType == MessageType.image &&
                        _msg is ImageMessage)
                    ? Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      (_msg as ImageMessage).content),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text('Photo'),
                          )
                        ],
                      )
                    : Text(
                        (_msg as TextMessage).content,
                        maxLines: 1,
                        style: const TextStyle(color: Colors.black54),
                      )
                : const Text(
                    '',
                    maxLines: 1,
                    style: TextStyle(color: Colors.black54),
                  ),
            trailing: _msg == null
                ? null
                : _msg!.readAt.isEmpty &&
                        _msg!.senderId != FirebaseService.user.uid
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      )
                    : Text(
                        MyDateUtils.getLastMessageTime(
                          context: context,
                          time: _msg!.createdAt,
                        ),
                        style: const TextStyle(color: Colors.black54),
                      ),
          );
        },
      ),
    );
  }
}
