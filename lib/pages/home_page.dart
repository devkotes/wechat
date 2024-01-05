import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/pages/profile_page.dart';
import 'package:wechat/pages/widgets/chat_user_card.dart';
import 'package:wechat/service/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> listUser = [];

  final List<ChatUser> searchUser = [];

  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    FirebaseService.getSelfInfo();

    // Setting user status to active
    FirebaseService.updateActiveStatus(true);

    // Update user active status according to lifecycle event
    // resume --> Active or Online
    // pause --> inactive or Offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (FirebaseService.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          FirebaseService.updateActiveStatus(true);
        }

        if (message.toString().contains('pause')) {
          FirebaseService.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    // PR : WillPopScope belum di Implementasikan :
    // Ketika di back, input search jadi unfocus

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: (!isSearch)
              ? const Text('We Chat')
              : TextField(
                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Name, Email, ...'),
                  autofocus: true,
                  style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                  onChanged: (value) {
                    searchUser.clear();

                    for (var i in listUser) {
                      if (i.name.toLowerCase().contains(value.toLowerCase()) ||
                          i.email.toLowerCase().contains(value.toLowerCase())) {
                        searchUser.add(i);
                      }
                      setState(() {
                        searchUser;
                      });
                    }
                  },
                ),
          centerTitle: true,
          leading: const Icon(
            Icons.home,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isSearch = !isSearch;
                  });
                },
                icon: Icon(isSearch
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(user: FirebaseService.me),
                  ));
                },
                icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: StreamBuilder(
          stream: FirebaseService.getAllUser(),
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
                listUser =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];
                if (listUser.isNotEmpty) {
                  return ListView.builder(
                    itemCount: (isSearch) ? searchUser.length : listUser.length,
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ChatUserCard(
                          user:
                              (isSearch) ? searchUser[index] : listUser[index]);
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(
            Icons.add_comment_rounded,
            // color: Colors.white,
          ),
        ),
      ),
    );
  }
}
