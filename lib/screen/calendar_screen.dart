import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:smuff_project/screen/gallerydetail_screen.dart';

class Calendar_Screen extends StatefulWidget {
  final String partnerUid;

  const Calendar_Screen({Key? key, required this.partnerUid}) : super(key: key);

  @override
  State<Calendar_Screen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<Calendar_Screen> {
  DateTime _focusedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  String? userId;
  List<String> imageUrls = [];
  List<String> partnerImageUrls = [];
  bool isLoadingImages = false;
  String? yid;
  Map<String, dynamic> partnerScheduleData = {};

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
    loadPartnerSchedule();
    _loadInitialImages();
  }

  Future<void> _loadInitialImages() async {
    await _loadImagesForDate(_selectedDate);
  }

  Future<void> loadPartnerSchedule() async {
    if (userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final fetchedYid = data?['yid'];

        if (fetchedYid != null) {
          setState(() {
            yid = fetchedYid;
          });
          await fetchPartnerSchedule(fetchedYid);
        } else {
          print('yid를 찾을 수 없습니다.');
        }
      } else {
        print('사용자 데이터를 찾을 수 없습니다.');
      }
    } catch (e) {
      print('yid를 가져오는 데 실패했습니다: $e');
    }
  }

  Future<void> fetchPartnerSchedule(String partnerYid) async {
    try {
      final partnerScheduleDoc = await FirebaseFirestore.instance
          .collection('dates')
          .doc(partnerYid)
          .get();

      if (partnerScheduleDoc.exists) {
        setState(() {
          partnerScheduleData = partnerScheduleDoc.data() ?? {};
        });
      } else {
        print('상대방의 일정 문서가 존재하지 않습니다.');
      }
    } catch (e) {
      print('상대방 일정을 가져오는 데 실패했습니다: $e');
    }
  }

  Future<void> fetchPartnerImagesForDate(DateTime date) async {
    if (yid == null) return;

    setState(() {
      isLoadingImages = true;
    });

    final List<String> urls = [];
    final String dateKey = DateFormat('yyyyMMdd').format(date);

    try {
      final storageRef = FirebaseStorage.instance.ref(yid!);
      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        if (item.name.contains(dateKey)) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }
      }
    } catch (e) {
      debugPrint("Error loading partner images: $e");
    }

    setState(() {
      partnerImageUrls = urls;
      isLoadingImages = false;
    });
  }

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
    });

    await fetchPartnerImagesForDate(date);
  }

  Future<void> _addEventToFirestore(String newEvent) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final updatedEvents = Map<String, List<String>>.from(
      currentEvents
          .map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    updatedEvents[dateKey] = [
      ...(updatedEvents[dateKey] ?? []),
      newEvent,
    ];

    try {
      await docRef.set({'events': updatedEvents}, SetOptions(merge: true));
      setState(() {});
    } catch (e) {
      debugPrint("Error adding event: $e");
    }
  }

  Future<void> _editEventsInFirestore(List<String> updatedEvents) async {
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('dates').doc(userId);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final snapshot = await docRef.get();
    final currentEvents = snapshot.exists &&
        snapshot.data() != null &&
        snapshot.data()!['events'] != null
        ? Map<String, dynamic>.from(snapshot.data()!['events'])
        : {};

    final newEvents = Map<String, List<String>>.from(
      currentEvents
          .map((key, value) => MapEntry(key, List<String>.from(value))),
    );

    newEvents[dateKey] = updatedEvents;

    await docRef.set({'events': newEvents}, SetOptions(merge: true));
    setState(() {});
  }

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
                              decoration:
                              const InputDecoration(hintText: '일정 제목 수정'),
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
                            decoration:
                            const InputDecoration(hintText: '새 일정 제목 입력'),
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
        backgroundColor: const Color(0xFFEC5F5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
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
                padding: const EdgeInsets.all(8.0),
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
                      return const Center(
                          child: Text("데이터를 불러오는 중 오류가 발생했습니다."));
                    }

                    final events = snapshot.data?.data() != null
                        ? Map<String, dynamic>.from(snapshot.data!.data()!
                    as Map<String, dynamic>)['events'] ??
                        {}
                        : {};

                    final dateKey =
                    DateFormat('yyyy-MM-dd').format(_selectedDate);
                    final List<String> eventsForSelectedDay =
                    events[dateKey] != null
                        ? List<String>.from(events[dateKey])
                        : [];

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: eventsForSelectedDay.isEmpty
                                      ? [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text('일정이 없습니다.',
                                          style: const TextStyle(
                                              fontSize: 16)),
                                    ),
                                  ]
                                      : [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text(
                                        '내 일정 : ' +
                                            eventsForSelectedDay
                                                .join(' '),
                                        style:
                                        const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
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
                                        decoration: const InputDecoration(
                                            hintText: "일정 입력"),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("취소"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (controller.text.isNotEmpty) {
                                              await _addEventToFirestore(
                                                  controller.text);
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
                              icon:
                              const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                _showEditEventsDialog(
                                    List.from(eventsForSelectedDay));
                              },
                            ),
                          ],
                        ),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('dates')
                              .doc(yid)
                              .snapshots(),
                          builder: (context, partnerSnapshot) {
                            if (partnerSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (partnerSnapshot.hasError) {
                              return const Center(
                                  child: Text("상대방의 일정을 불러오는 중 오류가 발생했습니다."));
                            }

                            final partnerData = partnerSnapshot.data?.data()
                            as Map<String, dynamic>? ??
                                {};
                            final partnerEvents = partnerData['events']
                            as Map<String, dynamic>? ??
                                {};
                            final partnerEventsForSelectedDay =
                            partnerEvents[dateKey] != null
                                ? List<String>.from(partnerEvents[dateKey])
                                : [];

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          if (partnerEventsForSelectedDay
                                              .isNotEmpty)
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 2.0),
                                              child: Text('상대방의 일정:',
                                                  style: const TextStyle(
                                                      fontSize: 16)),
                                            ),
                                          if (partnerEventsForSelectedDay
                                              .isNotEmpty)
                                            Row(
                                              children:
                                              partnerEventsForSelectedDay
                                                  .map((event) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Text(event,
                                                      style: const TextStyle(
                                                          fontSize: 16)),
                                                );
                                              }).toList(),
                                            )
                                          else
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: Text("상대방의 일정이 없습니다.",
                                                  style:
                                                  TextStyle(fontSize: 16)),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('내 사진',
                                              style: TextStyle(fontSize: 16)),
                                          SizedBox(
                                            height: 200,
                                            child: GridView.builder(
                                              gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 1,
                                              ),
                                              shrinkWrap: true,
                                              physics:
                                              AlwaysScrollableScrollPhysics(),
                                              // 스크롤 가능
                                              itemCount: imageUrls.length,
                                              // 모든 사진 표시
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GalleryDetailScreen(
                                                              imageUrls: imageUrls,
                                                              initialIndex: index,
                                                            ),
                                                      ),
                                                    );

                                                    // 반환된 삭제된 URL 처리
                                                    if (result != null &&
                                                        result is String) {
                                                      setState(() {
                                                        imageUrls
                                                            .remove(result);
                                                      });
                                                    }
                                                  },
                                                  child: Image.network(
                                                    imageUrls[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text('상대방 사진',
                                              style: TextStyle(fontSize: 16)),
                                          SizedBox(
                                            height: 200, // 원하는 높이 설정
                                            child: GridView.builder(
                                              gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 1,
                                              ),
                                              shrinkWrap: true,
                                              physics:
                                              AlwaysScrollableScrollPhysics(),
                                              // 스크롤 가능
                                              itemCount:
                                              partnerImageUrls.length,
                                              // 모든 사진 표시
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GalleryDetailScreen(
                                                              imageUrls:
                                                              partnerImageUrls,
                                                              initialIndex: index,
                                                            ),
                                                      ),
                                                    );
                                                    // 삭제된 이미지 URL 바로 반영
                                                    if (result != null &&
                                                        result is String) {
                                                      setState(() {
                                                        partnerImageUrls
                                                            .remove(result);
                                                      });
                                                    }
                                                  },
                                                  child: Image.network(
                                                    partnerImageUrls[index],
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
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
