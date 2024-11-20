import 'package:cloud_firestore/cloud_firestore.dart';

class DateModel {
  // id 필드를 제거했습니다.
  final DateTime firstDay;
  final int dday;
  final String userId;
  final String displayName;
  final String loversName;

  DateModel({
    required this.firstDay,
    required this.dday,
    required this.userId,
    required this.displayName,
    required this.loversName,
  });

  factory DateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DateModel(
      firstDay: (data['firstDay'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dday: data['dday'] ?? 0,
      // 기본값을 설정
      userId: data['userId'] ?? '',
      // 필드 이름을 userId로 변경
      displayName: data['displayName'] ?? '',
      loversName: data['loversName'] ?? '',
    );
  }

  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      'firstDay': forFirestore ? Timestamp.fromDate(firstDay) : firstDay
          .toIso8601String(),
      'dday': dday,
      'userId': userId,
      'displayName': displayName,
      'loversName': loversName,
    };
  }
}
