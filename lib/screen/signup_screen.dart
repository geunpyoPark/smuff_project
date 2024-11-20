import 'package:flutter/material.dart';
import 'package:smuff_project/screen/login_screen.dart';
class signup_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),

                // Back Button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => login_screen()), // SignUpScreen으로 이동
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Title
                Text(
                  'Create an account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Username TextField
                SizedBox(
                  height: 60,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Your Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Email TextField
                SizedBox(
                  height: 60,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Your Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Phone Number TextField
                SizedBox(
                  height: 60,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter Your Phone Number',
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
                      hintText: 'Enter Your Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Sign Up Button
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
                    child: Text('Sign Up',
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

                // Signup with Google Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:(){},
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

                // Login with Facebook Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:(){},
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
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
