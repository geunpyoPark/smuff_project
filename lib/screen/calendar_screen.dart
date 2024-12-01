import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String? userId;
  List<String> imageUrls = [];
  bool isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // 사용자 ID 가져오기
  Future<void> _fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      await _loadImagesForDate(_selectedDate);
    }
  }

  // 선택된 날짜에 해당하는 이미지만 불러오기
  Future<void> _loadImagesForDate(DateTime date) async {
    if (userId == null) return;

    setState(() {
      isLoadingImages = true;
    });

    final List<String> urls = [];
    final String dateKey = DateFormat('yyyyMMdd').format(date);

    try {
      final storageRef = FirebaseStorage.instance.ref(userId!);
      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        if (item.name.contains(dateKey)) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }
      }
    } catch (e) {
      debugPrint("Error loading images: $e");
    }

    setState(() {
      imageUrls = urls;
      isLoadingImages = false;
    });
  }

  // Firestore에 일정 추가
  Future<void> _addEventToFirestore(String newEvent) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists && snapshot.data() != null && snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final updatedEvents = Map<String, List<String>>.from(
      currentEvents.map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    updatedEvents[dateKey] = [
      ...(updatedEvents[dateKey] ?? []),
      newEvent,
    ];

    try {
      await docRef.set({'events': updatedEvents}, SetOptions(merge: true));
      setState(() {}); // 상태 업데이트를 통해 화면 갱신
    } catch (e) {
      debugPrint("Error adding event: $e");
    }
  }

  // Firestore에서 일정 수정
  Future<void> _editEventsInFirestore(List<String> updatedEvents) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists && snapshot.data() != null && snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final newEvents = Map<String, List<String>>.from(
      currentEvents.map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    newEvents[dateKey] = updatedEvents;

    await docRef.set({'events': newEvents}, SetOptions(merge: true));
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('캘린더', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0), // 추가적인 패딩을 넣어 아래쪽 overflow 방지
          child: Column(
            children: [
              TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                  await _loadImagesForDate(selectedDay);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('dates')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Center(child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
                    }

                    final events = snapshot.data?.data() != null
                        ? Map<String, dynamic>.from(snapshot.data!.data()! as Map<String, dynamic>)['events'] ?? {}
                        : {};

                    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
                    final List<String> eventsForSelectedDay = events[dateKey] != null
                        ? List<String>.from(events[dateKey])
                        : [];

                    return Column(
                      children: [
                        Row(
                          children: [
                            if (eventsForSelectedDay.isNotEmpty)
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: eventsForSelectedDay
                                        .map((event) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        event,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ))
                                        .toList(),
                                  ),
                                ),
                              )
                            else
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "일정이 존재하지 않습니다.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: () {
                                final TextEditingController controller = TextEditingController();
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
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("취소"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (controller.text.isNotEmpty) {
                                              await _addEventToFirestore(controller.text);
                                              Navigator.pop(context);
                                            }
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
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                _showEditEventsDialog(List.from(eventsForSelectedDay));
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 300,
                          child: isLoadingImages
                              ? const Center(child: CircularProgressIndicator())
                              : imageUrls.isEmpty
                              ? const Center(child: Text("해당 날짜에 저장된 이미지가 없습니다."))
                              : GridView.builder(
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
