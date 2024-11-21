import 'package:flutter/material.dart';

class GalleryDetail_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: Column(
            children: [
              SizedBox(height: 20),

              // 상단 사이즈박스
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // 이미지 영역
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://via.placeholder.com/300x200', // 실제 이미지 URL로 교체
                        fit: BoxFit.cover,
                      ),
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
