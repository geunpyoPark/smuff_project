import 'package:flutter/material.dart';

class setting_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              // 상단 사이즈박스
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // 배경 제목과 구분선
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '배경',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),

              // 배경 테마 선택 버튼
              SizedBox(
                width: 300,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text('배경 테마 선택'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // 배경 사진 선택 버튼
              SizedBox(
                width: 300,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  child: Text('배경 사진 선택'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),

              // 계정 제목과 구분선
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '계정',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 20),

              // 로그 아웃 버튼
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('로그 아웃', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
