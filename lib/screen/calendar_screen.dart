import 'package:flutter/material.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                // 캘린더 박스
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Colors.grey[300],
                        child: GridView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: 31,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 2,
                            crossAxisSpacing: 2,
                          ),
                          itemBuilder: (context, index) {
                            return Center(child: Text('${index + 1}'));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // 장소 텍스트와 추가 버튼
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('종로 중앙시장 데이트', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: Icon(Icons.add_box_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 이미지 격자와 지도
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: GridView.builder(
                          padding: EdgeInsets.all(8),
                          itemCount: 6,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(color: Colors.grey[300]),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://via.placeholder.com/200x150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
