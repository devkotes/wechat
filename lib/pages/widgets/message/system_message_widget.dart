import 'package:flutter/material.dart';
import 'package:wechat/helper/enum.dart';
import 'package:wechat/models/chat/chat.dart';
import 'package:wechat/models/chat_user.dart';

class SystemMessageWidget extends StatelessWidget {
  final SystemMessage message;
  final ChatUser user;
  final bool isMe;
  const SystemMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return (message.metadata.type != SystemMessageType.session)
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              // color: Colors.grey.shade100,
              child: Center(
                child: Text(message.metadata.title),
              ),
            ),
          )
        : SessionWidget(message: message);
  }
}

class SessionWidget extends StatelessWidget {
  final SystemMessage message;
  const SessionWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xffD7B9FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                message.metadata.title,
                style: const TextStyle(
                  color: Color(0xff302B2B),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xffF4EBFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Absensi ' '${message.metadata.title}',
                  style: const TextStyle(
                    color: Color(0xff302B2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint('ID SESSION ${message.metadata.id}');
                  },
                  child: Container(
                    width: 100,
                    height: 35,
                    decoration: BoxDecoration(
                      color: (message.metadata.isAttendance!)
                          ? const Color(0xff4285F4)
                          : const Color(0xffFF0A11),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        (message.metadata.isAttendance!)
                            ? 'Hadir'
                            : 'Belum Hadir',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
