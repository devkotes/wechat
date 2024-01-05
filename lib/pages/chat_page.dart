// import 'dart:convert';

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/my_date_utils.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/messages.dart';
import 'package:wechat/pages/view_profile_page.dart';
import 'package:wechat/pages/widgets/message_card.dart';

import '../service/firebase_service.dart';

class ChatPage extends StatefulWidget {
  final ChatUser user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> listMessage = [];

  late TextEditingController textController;

  bool _showEmoji = false;
  bool _isUploading = false;

  @override
  void initState() {
    textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // PR : WillPopScope belum di Implementasikan :
    //  ketika menggunakan emoji kemudian di back maka emoji nya di nonaktifkan
    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 236, 229, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseService.getAllMessage(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.blue.withOpacity(.5),
                          ),
                        );
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        listMessage = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (listMessage.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: listMessage.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(message: listMessage[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Say Hi! 👋 ',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: (_showEmoji) ? 0 : 20),
                child: _chatInput(),
              ),
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: textController,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 236, 229, 255),
                      columns: 8,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ViewProfilePage(user: widget.user),
        ));
      },
      child: StreamBuilder(
          stream: FirebaseService.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.black54,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: (list.isNotEmpty)
                        ? list.first.photoUrl
                        : widget.user.photoUrl,
                    width: mq.height * .05,
                    height: mq.height * .05,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (list.isNotEmpty) ? list.first.name : widget.user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      (list.isNotEmpty)
                          ? list.first.isOnline
                              ? 'Online'
                              : MyDateUtils.getLastActive(
                                  context: context,
                                  lastActive: list.first.lastActive)
                          : MyDateUtils.getLastActive(
                              context: context,
                              lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () => setState(() => _showEmoji = false),
                      decoration: const InputDecoration(
                        hintText: 'Type Something ...',
                        hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      // Multiple Image Picker
                      final ImagePicker picker = ImagePicker();

                      final List<XFile> images = await picker.pickMultiImage();

                      for (var img in images) {
                        setState(() => _isUploading = true);
                        await FirebaseService.sendChatImage(
                            widget.user, File(img.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      final XFile? images = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);

                      if (images != null) {
                        setState(() => _isUploading = true);
                        await FirebaseService.sendChatImage(
                            widget.user, File(images.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  SizedBox(width: mq.width * .02)
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                FirebaseService.sendMessage(
                  widget.user,
                  textController.text,
                  MessageType.text,
                );
                textController.clear();
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.deepPurpleAccent,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
