import 'package:flutter/material.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smuff_project/screen/signup_screen.dart';

class Login_Screen extends StatelessWidget {

  // Firestore에 사용자 데이터를 저장하는 함수
  Future<void> saveUserData(String uid, String displayName) async {
    final docRef = FirebaseFirestore.instance.collection('dates').doc(uid);

    // Firestore에서 사용자 데이터 확인
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // 데이터가 존재하지 않는 경우에만 저장
      await docRef.set({
        'displayName': displayName,
        'loversName': '상대방 이름', // 기본값
        'firstDay': Timestamp.now(),
        'dday': 0,
        'userId': uid,
      });
    }
  }
  //구글 로그인
  onGoogleLoginPress (BuildContext context)async{
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );
    try{
      //signIn 함수 실행해서 로그인 진행
      GoogleSignInAccount? account = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await account?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await saveUserData(userCredential.user!.uid, userCredential.user!.displayName ?? '사용자 이름');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => home_screen(),
        ),
      );
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패')),
      );
    }
  }
  //페이스북 로그인
  onFacebookLoginPress(BuildContext context) async {
    try {
      // Facebook 로그인 요청, 이메일 권한 추가
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email'], // 이메일 권한 요청
      );
      // 로그인 실패 처리
      if (result.status == LoginStatus.failed) {
        throw Exception('Facebook 로그인 실패');
      }
      // Access Token 가져오기
      final AccessToken? accessToken = result.accessToken;
      // Firebase 인증 자격 증명 생성
      final credential = FacebookAuthProvider.credential(accessToken!.token);
      // Firebase에 로그인
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      // Facebook 프로필 정보 가져오기
      final userData = await FacebookAuth.instance.getUserData();
      String displayName = userData['name'] ?? '사용자 이름'; // 이름 가져오기
      // Firestore에 사용자 데이터 저장
      await saveUserData(userCredential.user!.uid, displayName);
      // 로그인 성공 후 화면 전환
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => home_screen(), // HomeScreen으로 변경
        ),
      );
    } catch (error) {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 60),

                // Email TextField
                SizedBox(
                  height: 60,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@gmail.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Password TextField with Eye Icon
                SizedBox(
                  height: 60,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter Your Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Remember Me and Forgot Password Row
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(value: true, onChanged: (value) {}),
                          Text('Remember Me'),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Login',
                    style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Divider with 'Or With'
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Or With'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 20),

                // Login with Google Button
                Column(
                  children: [
                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => onGoogleLoginPress(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // 버튼 배경색
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          children: [
                            // 아이콘을 왼쪽으로 밀착
                            Image.asset(
                              'assets/img/Google Logo.png', // 구글 로고 이미지 경로
                              width: 20, // 아이콘 크기 조정
                              height: 20,
                            ),
                            SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                            Expanded(
                              child: Text(
                                'Login with Google',
                                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                style: TextStyle(color: Colors.black), // 텍스트 색상 변경
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Facebook Login Button
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
                            // 아이콘을 왼쪽으로 밀착
                            Icon(Icons.facebook, color: Colors.white, size: 25), // 아이콘 크기 조정
                            SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                            Expanded(
                              child: Text(
                                'Login with Facebook',
                                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Sign Up Text
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don’t have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Signup_Screen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
