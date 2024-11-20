import 'package:flutter/material.dart';
import 'package:smuff_project/screen/setting_screen.dart';
import 'package:smuff_project/screen/calendar_screen.dart';
import 'package:smuff_project/screen/camera_screen.dart';
import 'package:smuff_project/screen/gallery_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class home_screen extends StatefulWidget {
  final File? image;
  home_screen({this.image});
  @override
  State<home_screen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<home_screen> {
  String displayName = '사용자 이름';
  String loversName = '상대방 이름';
  DateTime firstDay = DateTime.now();
  int dday = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // 로그인 시 사용자 데이터 가져오기
  }

  // Firestore에 사용자 데이터 저장하는 함수
  Future<void> saveUserData(String uid, String displayName) async {
    final docRef = FirebaseFirestore.instance.collection('dates').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      // 문서가 없을 경우에만 초기 데이터를 저장
      await docRef.set({
        'displayName': displayName,
        'loversName': '상대방 이름', // 사용자가 입력하도록 설정할 수 있음
        'firstDay': DateTime.now(),
        'dday': 0,
      }, SetOptions(merge: true));
    }
  }
  // 사용자 데이터 가져오기
  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('dates').doc(user.uid).get();
    if (doc.exists) {
      setState(() {
        displayName = doc['displayName'] ?? '사용자 이름';
        loversName = doc['loversName'] ?? '상대방 이름';
        firstDay = (doc['firstDay'] as Timestamp).toDate();
        dday = doc['dday'] ?? 0;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false; // 데이터가 없을 경우에도 로딩 상태 해제
      });
      print('Firestore에 사용자 데이터가 없습니다.');
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => settings_screen()), // SettingsScreen으로 이동
              );
            },
            child: Image.asset(
              'assets/img/settings.png', // 설정 아이콘 이미지 경로
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance.collection('dates').doc(user.uid).snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('데이터 없음'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          String displayName = data['displayName'] ?? '사용자 이름';
          String loversName = data['loversName'] ?? '상대방 이름';
          DateTime firstDay = (data['firstDay'] as Timestamp).toDate();
          int dday = data['dday'] ?? 0;

          return Center(
            child: SizedBox(
              width: 411,
              height: 707,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$displayName ❤️ $loversName',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${firstDay.toString().substring(0, 10)} ~ $dday일 째',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // 이미지
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: 400,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.image != null
                            ? Image.file(
                          widget.image!,
                          fit: BoxFit.cover,
                        )
                            : Center(child: Text('이미지를 선택해주세요.')),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  // 하단 아이콘 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CalendarScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/calendar_month.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(height: 4),
                            Text('캘린더', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CameraScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/photo_camera.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(height: 4),
                            Text('카메라', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GalleryScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/broken_image.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox(height: 4),
                            Text('갤러리', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
