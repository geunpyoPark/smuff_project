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
  final PageController _pageController = PageController();
  Timer? _timer; // 타이머 변수
  int _currentPage = 0;
  final List<String> _backgroundImages = [
    'assets/img/bird.jpg', // 배경 이미지 1
    'assets/img/luda.jpg', // 배경 이미지 2
    'assets/img/123.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide(); // 자동 슬라이드 시작
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      // 현재 페이지를 증가시키고, 마지막 이미지를 넘으면 첫 번째 이미지로 돌아가도록 처리
      if (_currentPage < _backgroundImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // 마지막 이미지에서 첫 번째 이미지로 돌아가기
      }
      // 페이지 전환 애니메이션
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제
    _pageController.dispose(); // 페이지 컨트롤러 해제
    super.dispose();
  }

  // Firestore에 사용자 데이터를 저장하는 함수
  Future<void> saveUserData(String mid, String mname, String email) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(mid);

    // Firestore에서 사용자 데이터 확인
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // 데이터가 존재하지 않는 경우에만 저장
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

  // 구글 로그인
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

      // Firestore에 사용자 데이터 저장
      await saveUserData(
        userCredential.user!.uid,
        userCredential.user!.displayName ?? '사용자 이름',
        userCredential.user!.email ?? 'unknown@example.com',
      );

      // 로그인 성공 시 화면 이동
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => Home_Screen()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $error')),
      );
    }
  }

  // 페이스북 로그인
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

        // Firestore에 사용자 데이터 저장
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
          // 배경 이미지 슬라이드
          PageView.builder(
            controller: _pageController,
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _backgroundImages[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),

          // 로그인 UI
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 500,),
                  // Google Login Button
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
