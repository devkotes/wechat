import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/helper/my_date_utils.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/pages/widgets/message/custom_message_widget.dart';
import 'package:wechat/pages/widgets/message/system_message_widget.dart';
import 'package:wechat/pages/widgets/message/text_message_widget.dart';
import 'package:wechat/service/firebase_service.dart';

import '../../helper/dialogs.dart';
import '../../helper/enum.dart';
import '../../models/chat/chat.dart';
import 'message/image_message_widget.dart';

class MessageCard extends StatelessWidget {
  final ChatUser user;
  final ChatMessage message;
  const MessageCard({
    super.key,
    required this.message,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = FirebaseService.user.uid == message.senderId;
    return (message.messageType == MessageType.image)
        ? ImageMessageWidget(
            message: (message as ImageMessage), user: user, isMe: isMe)
        : (message.messageType == MessageType.system)
            ? SystemMessageWidget(
                message: (message as SystemMessage), user: user, isMe: isMe)
            : (message.messageType == MessageType.custom)
                ? CustomMessageWidget(
                    message: (message as CustomMessage), user: user, isMe: isMe)
                : InkWell(
                    onLongPress: () {
                      _showBottomSheet(context: context, isMe: isMe);
                    },
                    child: TextMessageWidget(
                      message: (message as TextMessage),
                      user: user,
                      isMe: isMe,
                    ),
                  );
  }

  // bottom sheet for modifying message details
  void _showBottomSheet({required BuildContext context, required bool isMe}) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              (message.messageType == MessageType.text &&
                      message is TextMessage)
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(
                                text: (message as TextMessage).content))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          debugPrint(
                              'Image Url: ${(message as ImageMessage).content}');
                          // await GallerySaver.saveImage(message.msg,
                          //         albumName: 'We Chat')
                          //     .then((success) {
                          //   //for hiding bottom sheet
                          //   Navigator.pop(context);
                          //   if (success != null && success) {
                          //     Dialogs.showSnackbar(
                          //         context, 'Image Successfully Saved!');
                          //   }
                          // });
                        } catch (e) {
                          debugPrint('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (message.messageType == MessageType.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      _showMessageUpdateDialog(context);
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await FirebaseService.deleteMessage(user, message)
                          .then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUtils.getMessageTime(context: context, time: message.createdAt)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: (message.readAt.isEmpty)
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtils.getMessageTime(context: context, time: message.readAt)}',
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog(BuildContext context) {
    String updatedMsg = (message as TextMessage).content;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                      FirebaseService.updateMessage(user, message, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
