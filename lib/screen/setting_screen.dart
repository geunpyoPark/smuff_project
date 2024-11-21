import 'package:flutter/material.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smuff_project/screen/login_screen.dart';
import 'package:smuff_project/model/date_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart'; //
import 'dart:io';

class Settings_Screen extends StatefulWidget {
  @override
  State<Settings_Screen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings_Screen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  DateTime firstDay = DateTime.now();
  List<DateModel> savedDates = [];
  String? currentDateId;
  String? displayName;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
  }
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  // 날짜 선택 함수
  void _selectDate() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = firstDay;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                ),
                CupertinoButton(
                  child: Text("확인"),
                  onPressed: () {
                    int dday = DateTime.now().difference(selectedDate).inDays + 1;
                    setState(() {
                      firstDay = selectedDate;
                    });

                    saveDateToFirestore(selectedDate, dday);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }

  void saveDateToFirestore(DateTime selectedDate, int dday) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('다시 로그인을 해주세요'),
        ),
      );
      return;
    }
    try {
      DocumentReference docRef = firestore.collection('dates').doc(user.uid);
      DocumentSnapshot doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'firstDay': Timestamp.fromDate(selectedDate.toUtc()), // UTC로 변환하여 저장
          'dday': dday,
        });
      } else {
        await docRef.set({
          'firstDay': Timestamp.fromDate(selectedDate.toUtc()), // UTC로 변환하여 저장
          'dday': dday,
          'userId': user.uid,
        });
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }
  void saveLoversName() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("상대방 이름 설정"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "상대방의 이름을 입력하세요"),
          ),
          actions: [
            TextButton(
              child: Text("취소"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("저장"),
              onPressed: () {
                String loverName = nameController.text.trim();
                if (loverName.isNotEmpty) {
                  saveLoverNameToFirestore(loverName);
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("이름을 입력해 주세요.")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void saveLoverNameToFirestore(String loverName) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('다시 로그인을 해주세요')),
      );
      return;
    }
    try {
      DocumentReference docRef = firestore.collection('dates').doc(user.uid);
      // 상대방 이름을 Firestore에 저장합니다.
      await docRef.set({
        'loversName': loverName, // 상대방 이름 저장
      }, SetOptions(merge: true)); // 기존 데이터와 병합하여 저장

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('상대방의 이름이 저장되었습니다.')),
      );
    } catch (e) {
      print('오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이름 저장에 실패했습니다.')),
      );
    }
  }
  // 이미지 선택 함수
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // 선택한 이미지의 경로를 File로 변환
      });

      // 선택한 이미지를 HomeScreen에 전달하여 보여줍니다.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => home_screen(image: _selectedImage), // 선택한 이미지를 전달
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 411,
          height: 720,
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                // 상단 사이즈박스
                SizedBox(
                  height: 50,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.home, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => home_screen()), // HomeScreen으로 이동
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // 배경 제목과 구분선
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '배경',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 20),

                // 배경 테마 선택 버튼
                SizedBox(
                  width: 300,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('배경 테마 선택'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // 배경 사진 선택 버튼
                SizedBox(
                  width: 300,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _pickImage,
                    child: Text('메인 사진 선택'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 150),
                // 계정 제목과 구분선
                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '계정',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: 20),
                // 날짜 설정 버튼
                SizedBox(
                  width: 300,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _selectDate, // 날짜 선택 함수 호출
                    child: Text('날짜 설정'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: saveLoversName, // 날짜 선택 함수 호출
                    child: Text('상대방 이름 설정'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // 로그 아웃 버튼
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await signOut(); // 로그아웃 함수 호출
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => Login_Screen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 30.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10), // 아이콘과 텍스트 간격
                        Text(
                          '로그 아웃',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

