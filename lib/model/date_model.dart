import 'package:cloud_firestore/cloud_firestore.dart';

class DateModel {
  final DateTime firstDay;
  final int dday;
  final String userId;
  final String displayName;
  final String loversName;
  final Map<DateTime, List<String>> events; // 날짜별 일정 저장

  DateModel({
    required this.firstDay,
    required this.dday,
    required this.userId,
    required this.displayName,
    required this.loversName,
    this.events = const {}, // 기본값 빈 맵
  });

  // Firestore 데이터에서 DateModel로 변환
  factory DateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DateModel(
      firstDay: (data['firstDay'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dday: data['dday'] ?? 0,
      userId: data['userId'] ?? '',
      displayName: data['displayName'] ?? '',
      loversName: data['loversName'] ?? '',
      events: (data['events'] as Map<String, dynamic>?)
          ?.map((key, value) {
        final date = DateTime.parse(key); // Firestore 키를 DateTime으로 변환
        final eventList = (value as List<dynamic>).cast<String>();
        return MapEntry(date, eventList);
      }) ??
          {},
    );
  }

  // DateModel에서 Firestore 데이터로 변환
  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      'firstDay': forFirestore
          ? Timestamp.fromDate(firstDay) // Firestore 저장용 Timestamp
          : firstDay.toIso8601String(), // 일반 JSON 저장용 ISO8601 문자열
      'dday': dday,
      'userId': userId,
      'displayName': displayName,
      'loversName': loversName,
      'events': events.map(
            (key, value) => MapEntry(
          key.toIso8601String().split('T')[0], // 날짜를 "yyyy-MM-dd" 문자열로 변환
          value,
        ),
      ),
    };
  }
}
