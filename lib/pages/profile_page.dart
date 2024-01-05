import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/pages/auth/login_page.dart';
import 'package:wechat/service/firebase_service.dart';

class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          leading: const Icon(
            Icons.home,
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      (_image != null)
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                fit: BoxFit.cover,
                                width: mq.height * .2,
                                height: mq.height * .2,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.photoUrl,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.deepPurple,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (newValue) =>
                        FirebaseService.me.name = newValue ?? '',
                    validator: (value) => (value != null && value.isNotEmpty)
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Dadang Casper',
                      label: const Text('Name'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (newValue) =>
                        FirebaseService.me.about = newValue ?? '',
                    validator: (value) => (value != null && value.isNotEmpty)
                        ? null
                        : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.info_outline_rounded,
                          color: Colors.deepPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'eg. Feeling happy',
                      label: const Text('About'),
                    ),
                  ),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: Size(mq.width * .5, mq.height * .06),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        debugPrint('UPDATE!!');
                        _formKey.currentState!.save();
                        FirebaseService.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, 'Profile Update Successfuly');
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'UPDATE',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            Dialogs.showProgressBar(context);

            FirebaseService.updateActiveStatus(false);

            await FirebaseAuth.instance.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                Navigator.pop(context);
                FirebaseService.auth = FirebaseAuth.instance;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ));
              });
            });
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
          children: [
            const Text(
              'Pick Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: mq.height * .02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? file = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (file != null) {
                      debugPrint('Image Path : ${file.path}');
                      debugPrint('Image MimeType : ${file.mimeType}');
                      setState(() {
                        _image = file.path;
                      });
                      FirebaseService.updateProfilePicture(File(_image!));

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Image.asset('assets/images/gallery.png'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    fixedSize: Size(mq.width * .3, mq.height * .15),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();

                    final XFile? file = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (file != null) {
                      debugPrint('Image Path : ${file.path}');
                      debugPrint('Image MimeType : ${file.mimeType}');
                      setState(() {
                        _image = file.path;
                      });
                      FirebaseService.updateProfilePicture(File(_image!));

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Image.asset('assets/images/camera.png'),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
