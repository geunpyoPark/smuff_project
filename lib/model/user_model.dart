import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String mid;
  final String mname;
  final String yid;
  final String yname;
  final DateTime firstlogin;
  final String? mainimg; // 이미지 URL 필드
  final String email;
  final DateTime firstday;
  final int dday;

  UserModel({
    required this.mid,
    required this.mname,
    required this.yid,
    required this.yname,
    required this.firstlogin,
    required this.email,
    this.mainimg,
    required this.firstday,
    required this.dday,
  });

  // Firestore 데이터에서 UserModel로 변환
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      mid: data['mid'] ?? '',
      mname: data['mname'] ?? '',
      yid: data['yid'] ?? '',
      yname: data['yname'] ?? '',
      firstlogin: (data['firstlogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      email: data['email'] ?? '',
      mainimg: data['mainimg'] ?? data['imageUrl'], // Firestore의 mainimg 또는 imageUrl 필드 매핑
      firstday: (data['firstday'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dday: data['dday'] ?? 0,
    );
  }

  // UserModel을 Firestore 데이터로 변환
  Map<String, dynamic> toMap({bool forFirestore = true}) {
    return {
      'mid': mid,
      'mname': mname,
      'yid': yid,
      'yname': yname,
      'firstlogin': forFirestore
          ? Timestamp.fromDate(firstlogin)
          : firstlogin.toIso8601String(),
      if (mainimg != null) 'mainimg': mainimg,
      'email': email,
      'firstday': forFirestore
          ? Timestamp.fromDate(firstday)
          : firstday.toIso8601String(),
      'dday': dday,
    };
  }
}
