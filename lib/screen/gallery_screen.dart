import 'package:flutter/material.dart';

class Gallery_Screen extends StatelessWidget {
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
                      icon: Icon(Icons.home, color: Colors.black),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // 갤러리 그리드
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    itemCount: 1000, // 충분한 아이템 개수로 설정
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      // 모든 그리드 항목을 빈 박스로 표시
                      return SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(color: Colors.grey[300]),
                        ),
                      );
                    },
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
