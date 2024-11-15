import 'package:flutter/material.dart';

class home_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: Column(
            children: [
              SizedBox(height: 10),

              // 이름 및 날짜 정보
              Column(
                children: [
                  SizedBox(
                    width: 150, // 너비 지정
                    child: Text(
                      '종원❤️유진',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 4),
                  SizedBox(
                    width: 150, // 너비 지정
                    child: Text(
                      '2019.10.24~ 1849일 째',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 이미지
              SizedBox(
                width: 300,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://via.placeholder.com/300x200',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // 하단 아이콘 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today, size: 30),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt, size: 30),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.photo, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
