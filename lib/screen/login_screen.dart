import 'package:flutter/material.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Login_Screen extends StatefulWidget {
  @override
  State<Login_Screen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login_Screen> {
  final PageController _pageController = PageController(initialPage: 1000);
  Timer? _timer;
  int _currentPage = 1000;

  final List<String> _backgroundImages = [
    'assets/img/login1.jpg',
    'assets/img/login2.jpg',
    'assets/img/login3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> saveUserData(String mid, String mname, String email) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(mid);

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      await docRef.set({
        'mname': mname,
        'email': email,
        'mid': mid,
        'firstlogin': Timestamp.now(),
        'yid': null,
        'yname': null,
      });
    }
  }

  Future<void> onGoogleLoginPress(BuildContext context) async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    try {
      GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await account?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      await saveUserData(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? '사용자 이름',
        userCredential.user!.email ?? 'unknown@example.com',
      );

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Home_Screen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $error')),
      );
    }
  }

  Future<void> onFacebookLoginPress(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final credential = FacebookAuthProvider.credential(accessToken.token);

        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        final userData = await FacebookAuth.instance.getUserData();
        String mname = userData['name'] ?? '사용자 이름';
        String email = userData['email'] ?? 'unknown@example.com';

        await saveUserData(
          userCredential.user!.uid,
          mname,
          email,
        );

        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => Home_Screen()),
        );
      } else {
        throw Exception('Facebook 로그인 실패: ${result.message}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final imageIndex = index % _backgroundImages.length;
              return Image.asset(
                _backgroundImages[imageIndex],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 550),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => onGoogleLoginPress(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/img/Google Logo.png',
                                width: 20,
                                height: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Login with Google',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => onFacebookLoginPress(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4267B2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.facebook, color: Colors.white, size: 25),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Login with Facebook',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
