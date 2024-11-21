import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now(); // 현재 포커스된 날짜
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜
  Map<DateTime, List<String>> _events = {}; // Firestore에서 가져온 일정 저장
  String? userId; // 로그인된 사용자 ID

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // 사용자 ID 가져오기
  }

  // Firestore에서 일정 데이터를 스트림으로 가져오기
  Stream<Map<DateTime, List<String>>> _getEventsStream() {
    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);
    return docRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return {};
      }
      final data = snapshot.data()!;
      final events = (data['events'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          DateTime.parse(key),
          (value as List<dynamic>).cast<String>(),
        ),
      ) ??
          {};
      debugPrint("Fetched events: $events"); // 디버깅 출력
      return events;
    });
  }

  // Firestore에 일정 추가
  Future<void> _addEventToFirestore(String newEvent) async {
    if (userId == null) return; // 사용자 ID가 없는 경우 반환

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);

    final dateKey = _selectedDate.toIso8601String().split('T')[0]; // yyyy-MM-dd 형식의 키
    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists && snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final updatedEvents = Map<String, List<String>>.from(
      currentEvents.map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    updatedEvents[dateKey] = [
      ...(updatedEvents[dateKey] ?? []),
      newEvent,
    ];

    await docRef.set({
      'events': updatedEvents,
    }, SetOptions(merge: true));

    debugPrint("Saved events: $updatedEvents"); // 디버깅 출력
  }

  // Firestore에서 일정 수정
  Future<void> _editEventsInFirestore(List<String> updatedEvents) async {
    if (userId == null) return; // 사용자 ID가 없는 경우 반환

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);

    final dateKey = _selectedDate.toIso8601String().split('T')[0]; // yyyy-MM-dd 형식의 키
    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists && snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final newEvents = Map<String, List<String>>.from(
      currentEvents.map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    newEvents[dateKey] = updatedEvents;

    await docRef.set({
      'events': newEvents,
    }, SetOptions(merge: true));
  }

  // 일정 수정 다이얼로그
  void _showEditEventsDialog(List<String> currentEvents) {
    final TextEditingController _newEventController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('일정 수정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...currentEvents.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final String event = entry.value;

                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(text: event),
                              decoration: const InputDecoration(hintText: '일정 제목 수정'),
                              onChanged: (value) {
                                currentEvents[index] = value;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                currentEvents.removeAt(index);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newEventController,
                            decoration: const InputDecoration(hintText: '새 일정 제목 입력'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () {
                            if (_newEventController.text.isNotEmpty) {
                              setState(() {
                                currentEvents.add(_newEventController.text);
                                _newEventController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    await _editEventsInFirestore(currentEvents);
                    Navigator.pop(context);
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 로그인된 사용자 ID 가져오기
  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      debugPrint("User not logged in.");
    }
  }

  List<String> _getEventsForDay(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day); // 시간 정보 제거
    return _events[dateKey] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('캘린더', style: TextStyle(color: Colors.white)),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<Map<DateTime, List<String>>>(
        stream: _getEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          _events = snapshot.data!;

          return Column(
            children: [
              TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getEventsForDay(_selectedDate).join(', '),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final TextEditingController controller =
                      TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("일정 추가"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(hintText: "일정 입력"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context), // 취소 버튼
                                child: const Text("취소"),
                              ),
                              TextButton(
                                onPressed: () {
                                  _addEventToFirestore(controller.text);
                                  Navigator.pop(context);
                                },
                                child: const Text("추가"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit), // 수정 버튼 추가
                    onPressed: () {
                      final currentEvents = _getEventsForDay(_selectedDate);
                      _showEditEventsDialog(List.from(currentEvents));
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
