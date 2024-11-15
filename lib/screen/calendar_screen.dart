import 'package:flutter/material.dart';
import 'package:smuff_project/component/main_calendar.dart';
import 'package:smuff_project/screen/home_screen.dart'; // home_screen.dart를 임포트

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      this.selectedDate = selectedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.black),
          onPressed: () {
            // 홈 화면으로 이동하는 로직
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home_screen()),
            );
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 411,
          height: 707,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 캘린더 박스
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: MainCalendar(
                        selectedDate: selectedDate,
                        onDaySelected: onDaySelected,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // 장소 텍스트와 추가 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '종로 중앙시장 데이트',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: Icon(Icons.add_box_outlined),
                        onPressed: () {
                          // 추가 버튼의 동작 구현
                        },
                      ),
                    ],
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
                            padding: EdgeInsets.all(4),
                            itemCount: 4,
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
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            'https://via.placeholder.com/200x150',
                            fit: BoxFit.cover,
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
      ),
    );
  }
}
