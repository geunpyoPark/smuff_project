import 'package:flutter/material.dart';

class camera_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // 상단과 하단의 배경색 설정
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 상단 아이콘 영역
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.home, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              // 중간 빈 공간
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),

              // 하단 아이콘 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 중간 카메라 버튼
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: IconButton(
                        iconSize: 70, // 원형 촬영 버튼 크기
                        icon: Icon(Icons.circle, color: Colors.white, size: 70),
                        onPressed: () {},
                      ),
                    ),

                    // 갤러리 아이콘
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: IconButton(
                        icon: Icon(Icons.photo, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
