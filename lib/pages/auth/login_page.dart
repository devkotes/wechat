import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/pages/home_page.dart';

import '../../service/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isAnimate = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
        const Duration(
          milliseconds: 500,
        ), () {
      setState(() {
        isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome We Chat'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            right: (isAnimate) ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('assets/images/logo.png'),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                shape: const StadiumBorder(),
                elevation: 1,
              ),
              onPressed: () {
                handleLogin();
              },
              icon: Image.asset(
                'assets/images/google.png',
                height: mq.height * .03,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(text: 'Sign in with '),
                    TextSpan(
                      text: 'Google',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  handleLogin() async {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        debugPrint('\nUSER : ${user.user}');
        debugPrint('\nUSERAdditional : ${user.additionalUserInfo}');

        if (await FirebaseService.userExist()) {
          if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
          }
        } else {
          if (mounted) {
            await FirebaseService.createUser().then((value) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ));
            });
          }
        }
      } else {
        debugPrint('Login Cancel');
        Dialogs.showSnackbar(
            context, 'Something went wrong (Check Internet Connection)');
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseService.auth.signInWithCredential(credential);
    } catch (error) {
      debugPrint('login Error $error');
      if (context.mounted) {
        Dialogs.showSnackbar(
            context, 'Something went wrong (Check internet!!)');
      }
      return null;
    }
  }
}
